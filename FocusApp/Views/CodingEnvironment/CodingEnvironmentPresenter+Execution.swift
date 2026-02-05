import Foundation

extension CodingEnvironmentPresenter {
    func runCode() {
        guard !isRunning else { return }
        if testCases.isEmpty {
            runSingle()
        } else {
            executeTests(saveSubmission: false)
        }
    }

    func runTests() {
        guard !testCases.isEmpty else { return }
        executeTests(saveSubmission: true)
    }

    func stopExecution() {
        guard isRunning else { return }
        runTask?.cancel()
        interactor.cancelExecution()
        runTask = nil
        isRunning = false
        errorOutput = "Execution stopped by user."
    }

    private func wrappedCodeForExecution() -> String {
        guard let meta = LeetCodeMetaData.decode(from: problemContent?.metaData) else { return code }
        return LeetCodeExecutionWrapper.wrap(code: code, language: language, meta: meta)
    }

    private func runSingle() {
        isRunning = true
        compilationOutput = ""
        errorOutput = ""

        runTask?.cancel()
        runTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.runTask = nil
                }
            }
            let executionCode = self.wrappedCodeForExecution()
            let runInput = testCases.first?.input ?? ""
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: runInput
            )

            guard !Task.isCancelled else { return }
            await MainActor.run {
                if result.wasCancelled {
                    self.errorOutput = "Execution stopped by user."
                } else if result.timedOut {
                    self.errorOutput = "Execution timed out (10 second limit)"
                } else if !result.error.isEmpty {
                    self.errorOutput = result.error
                } else {
                    self.compilationOutput = result.output
                }
                self.errorDiagnostics = self.extractDiagnostics(
                    from: result.error,
                    language: self.language,
                    code: self.code
                )
                self.isRunning = false
            }
        }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    private func executeTests(saveSubmission: Bool) {
        guard !isRunning else { return }
        isRunning = true
        compilationOutput = ""
        errorOutput = ""

        runTask?.cancel()
        runTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.runTask = nil
                }
            }
            var updatedTestCases = testCases
            var consoleLogs: [String] = []
            var errorLogs: [String] = []
            let executionCode = self.wrappedCodeForExecution()
            var allPassed = true

            for index in updatedTestCases.indices {
                if Task.isCancelled { break }
                let testCase = updatedTestCases[index]
                let result = await interactor.executeCode(
                    code: executionCode,
                    language: language,
                    input: testCase.input
                )

                if Task.isCancelled { break }
                await MainActor.run {
                    if result.wasCancelled {
                        updatedTestCases[index].actualOutput = "Stopped"
                        updatedTestCases[index].passed = false
                    } else if result.timedOut {
                        updatedTestCases[index].actualOutput = "Timed out"
                        updatedTestCases[index].passed = false
                    } else if !result.error.isEmpty {
                        updatedTestCases[index].actualOutput = "Error: \(result.error)"
                        updatedTestCases[index].passed = false
                    } else {
                        let normalizedExpected = testCase.expectedOutput
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        let normalizedActual = self.normalizeOutputForComparison(
                            result.output,
                            expected: normalizedExpected
                        )
                        updatedTestCases[index].actualOutput = normalizedActual
                        updatedTestCases[index].passed = normalizedActual == normalizedExpected
                    }
                    if updatedTestCases[index].passed != true {
                        allPassed = false
                    }
                    self.testCases = updatedTestCases
                }

                if !result.output.isEmpty {
                    consoleLogs.append("Test \(index + 1):\n\(result.output)")
                }

                if !result.error.isEmpty {
                    errorLogs.append("Test \(index + 1):\n\(result.error)")
                }
            }

            guard !Task.isCancelled else { return }
            if saveSubmission, allPassed {
                await MainActor.run {
                    self.prepareSubmissionPrompt()
                }
            }
            await MainActor.run {
                if !consoleLogs.isEmpty {
                    self.compilationOutput = consoleLogs
                        .joined(separator: "\n\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }

                if !errorLogs.isEmpty {
                    self.errorOutput = errorLogs
                        .joined(separator: "\n\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
                let combinedError = errorLogs.joined(separator: "\n")
                self.errorDiagnostics = self.extractDiagnostics(
                    from: combinedError,
                    language: self.language,
                    code: self.code
                )
                self.isRunning = false
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    private func recordSubmission() {
        guard let problem = selectedProblem else { return }
        let key = submissionKey(for: problem)
        interactor.addSubmission(code: code, language: language, for: key)
    }

    private func prepareSubmissionPrompt() {
        guard let problem = selectedProblem else { return }
        pendingSubmission = PendingSubmission(problem: problem, code: code, language: language)
        submissionTagInput = ""
        showSubmissionTagPrompt = true
    }

    func confirmSubmissionTag(saveWithTag: Bool) {
        guard let pending = pendingSubmission else { return }
        let tag = saveWithTag ? submissionTagInput : nil
        let key = submissionKey(for: pending.problem)
        interactor.addSubmission(code: pending.code, language: pending.language, algorithmTag: tag, for: key)
        pendingSubmission = nil
        submissionTagInput = ""
        showSubmissionTagPrompt = false
    }

    private func extractDiagnostics(
        from errorOutput: String,
        language: ProgrammingLanguage,
        code: String
    ) -> [CodeEditorDiagnostic] {
        guard !errorOutput.isEmpty else { return [] }
        let codeLineCount = max(
            code.split(separator: "\n", omittingEmptySubsequences: false).count,
            1
        )
        var collector = DiagnosticCollector(codeLineCount: codeLineCount)

        switch language {
        case .swift:
            parseSwiftDiagnostics(errorOutput, collector: &collector)
        case .python:
            parsePythonDiagnostics(errorOutput, collector: &collector)
        }

        if collector.results.isEmpty {
            addFallbackDiagnostics(from: errorOutput, collector: &collector)
        }

        return collector.results
    }

    private func parseSwiftDiagnostics(_ errorOutput: String, collector: inout DiagnosticCollector) {
        let pattern = "([^\\s:]+\\.swift):(\\d+):(\\d+):\\s*error:\\s*(.+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        let range = NSRange(location: 0, length: (errorOutput as NSString).length)
        for match in regex.matches(in: errorOutput, range: range) {
            guard match.numberOfRanges >= 4 else { continue }
            let lineString = (errorOutput as NSString).substring(with: match.range(at: 2))
            let columnString = (errorOutput as NSString).substring(with: match.range(at: 3))
            let message = (errorOutput as NSString).substring(with: match.range(at: 4))
            guard let line = Int(lineString) else { continue }
            let column = Int(columnString)
            collector.add(line: line, column: column, message: message, offset: 0)
        }
    }

    private func parsePythonDiagnostics(_ errorOutput: String, collector: inout DiagnosticCollector) {
        let lines = errorOutput.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        let fallbackMessage = extractPythonFallbackMessage(from: lines)

        guard let fileRegex = try? NSRegularExpression(
            pattern: "File \\\"([^\\\"]+)\\\", line (\\d+)",
            options: []
        ) else {
            return
        }

        for index in lines.indices {
            let line = String(lines[index])
            let lineRange = NSRange(location: 0, length: (line as NSString).length)
            guard let match = fileRegex.firstMatch(in: line, range: lineRange),
                  match.numberOfRanges >= 3 else { continue }
            let lineString = (line as NSString).substring(with: match.range(at: 2))
            guard let lineNumber = Int(lineString) else { continue }

            let (column, message) = parsePythonCaret(at: index, lines: lines)
            let finalMessage = message ?? fallbackMessage ?? "Error"
            collector.add(line: lineNumber, column: column, message: finalMessage, offset: 0)
        }
    }

    private func extractPythonFallbackMessage(from lines: [Substring]) -> String? {
        for line in lines.reversed() {
            let trimmed = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            if trimmed.contains("Error") || trimmed.contains("Exception") {
                return trimmed
            }
        }
        return nil
    }

    private func parsePythonCaret(at index: Int, lines: [Substring]) -> (Int?, String?) {
        guard index + 2 < lines.count else { return (nil, nil) }
        let caretLine = String(lines[index + 2])
        guard let caretIndex = caretLine.firstIndex(of: "^") else { return (nil, nil) }
        let column = caretLine.distance(from: caretLine.startIndex, to: caretIndex) + 1

        guard index + 3 < lines.count else { return (column, nil) }
        let candidate = String(lines[index + 3]).trimmingCharacters(in: .whitespacesAndNewlines)
        return (column, candidate.isEmpty ? nil : candidate)
    }

    private func addFallbackDiagnostics(from errorOutput: String, collector: inout DiagnosticCollector) {
        let fallbackPattern = "(?:^|\\n)\\s*(\\d+)\\s*\\|"
        guard let regex = try? NSRegularExpression(pattern: fallbackPattern, options: []) else { return }
        let range = NSRange(location: 0, length: (errorOutput as NSString).length)
        for match in regex.matches(in: errorOutput, range: range) {
            guard match.numberOfRanges >= 2 else { continue }
            let lineString = (errorOutput as NSString).substring(with: match.range(at: 1))
            if let line = Int(lineString) {
                collector.add(line: line, column: nil, message: "Error", offset: 0)
            }
        }
    }

    private struct DiagnosticCollector {
        let codeLineCount: Int
        var results: [CodeEditorDiagnostic] = []
        var seen: Set<CodeEditorDiagnostic> = []

        mutating func add(line: Int, column: Int?, message: String, offset: Int) {
            let userLine = line - offset
            guard userLine >= 1 else { return }
            let clampedLine = min(userLine, codeLineCount)
            let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalMessage = trimmedMessage.isEmpty ? "Error" : trimmedMessage
            let diagnostic = CodeEditorDiagnostic(line: clampedLine, column: column, message: finalMessage)
            if seen.insert(diagnostic).inserted {
                results.append(diagnostic)
            }
        }
    }

    func normalizeOutputForComparison(_ output: String, expected: String) -> String {
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedExpected.isEmpty {
            return trimmedOutput
        }

        if trimmedOutput == trimmedExpected {
            return trimmedOutput
        }

        if trimmedOutput.hasSuffix(trimmedExpected) {
            return trimmedExpected
        }

        if !trimmedExpected.contains("\n") {
            let lastLine = trimmedOutput.split(whereSeparator: \.isNewline).last
            return lastLine.map(String.init) ?? trimmedOutput
        }

        return trimmedOutput
    }
}
