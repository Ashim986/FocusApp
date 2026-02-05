import Foundation

extension CodingEnvironmentPresenter {
    func runCode() {
        guard !isRunning else { return }
        clearJourney()
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
            let parsed = parseTraceOutput(result.output)
            await MainActor.run {
                if result.wasCancelled {
                    self.errorOutput = "Execution stopped by user."
                } else if result.timedOut {
                    self.errorOutput = "Execution timed out (10 second limit)"
                } else if !result.error.isEmpty {
                    self.errorOutput = result.error
                } else {
                    self.compilationOutput = parsed.cleanOutput
                }
                self.errorDiagnostics = self.extractDiagnostics(
                    from: result.error,
                    language: self.language,
                    code: self.code
                )
                if result.isSuccess, !parsed.events.isEmpty {
                    self.updateJourney(parsed.events, truncated: parsed.isTruncated)
                }
                self.isRunning = false
            }
        }
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    private func executeTests(saveSubmission: Bool) {
        guard !isRunning else { return }
        clearJourney()
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
                let parsed = parseTraceOutput(result.output)
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
                            parsed.cleanOutput,
                            expected: normalizedExpected
                        )
                        updatedTestCases[index].actualOutput = normalizedActual
                        updatedTestCases[index].passed = normalizedActual == normalizedExpected
                    }
                    if updatedTestCases[index].passed != true {
                        allPassed = false
                    }
                    self.testCases = updatedTestCases
                    if index == 0, result.isSuccess, !parsed.events.isEmpty {
                        self.updateJourney(parsed.events, truncated: parsed.isTruncated)
                    }
                }

                if !parsed.cleanOutput.isEmpty {
                    consoleLogs.append("Test \(index + 1):\n\(parsed.cleanOutput)")
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

}
