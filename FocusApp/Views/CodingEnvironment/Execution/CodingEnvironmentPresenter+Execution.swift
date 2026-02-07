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
        guard !isRunning else { return }
        if testCases.isEmpty {
            submitWithoutLocalTests()
        } else {
            executeTests(saveSubmission: true)
        }
    }

    func stopExecution() {
        guard isRunning else { return }
        runTask?.cancel()
        interactor.cancelExecution()
        runTask = nil
        isRunning = false
        errorOutput = "Execution stopped by user."
    }

    func wrappedCodeForExecution() -> String {
        wrappedCodeForExecution(code, language: language)
    }

    func wrappedCodeForExecution(_ source: String, language: ProgrammingLanguage) -> String {
        guard let meta = LeetCodeMetaData.decode(from: problemContent?.metaData) else { return source }
        return LeetCodeExecutionWrapper.wrap(code: source, language: language, meta: meta)
    }

    private func runSingle() {
        isRunning = true
        compilationOutput = ""
        errorOutput = ""
        executionLogAnchor = Date()

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
    private func submitWithoutLocalTests() {
        clearJourney()
        isRunning = true
        compilationOutput = ""
        errorOutput = ""
        executionLogAnchor = Date()
        showSubmissionTagPrompt = false
        pendingSubmission = nil
        submissionTagInput = ""

        runTask?.cancel()
        runTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.runTask = nil
                }
            }

            // Step 1: Resolve AI test cases
            let aiCases = await self.resolveAITestCasesForPanel()
            guard !aiCases.isEmpty, !Task.isCancelled else {
                await MainActor.run {
                    self.isRunning = false
                }
                return
            }

            // Step 2: Populate them into the test case panel
            let localTestCases = aiCases.map { TestCase(input: $0.input, expectedOutput: $0.expectedOutput) }
            await MainActor.run {
                self.testCases = localTestCases
            }

            // Step 3: Run user's code against each AI test case
            var updatedTestCases = localTestCases
            var consoleLogs: [String] = []
            var errorLogs: [String] = []
            let executionCode = self.wrappedCodeForExecution()
            var allPassed = true

            for index in updatedTestCases.indices {
                if Task.isCancelled { break }
                await MainActor.run {
                    self.compilationOutput = "Running AI test \(index + 1) of \(updatedTestCases.count)…"
                }
                let result = await interactor.executeCode(
                    code: executionCode,
                    language: language,
                    input: updatedTestCases[index].input
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
                    } else if result.exitCode != 0 {
                        updatedTestCases[index].actualOutput = "Error: \(result.error)"
                        updatedTestCases[index].passed = false
                    } else {
                        let normalizedExpected = updatedTestCases[index].expectedOutput
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        let normalized = self.normalizeOutputForComparison(
                            parsed.cleanOutput,
                            expected: normalizedExpected
                        )
                        updatedTestCases[index].actualOutput = normalized.displayValue
                        if normalizedExpected.isEmpty {
                            updatedTestCases[index].passed = nil
                        } else {
                            updatedTestCases[index].passed = normalized.comparisonValue == normalizedExpected
                        }
                    }
                    if updatedTestCases[index].passed != true {
                        allPassed = false
                    }
                    self.testCases = updatedTestCases
                    if result.exitCode == 0, !result.timedOut, !result.wasCancelled, !parsed.events.isEmpty {
                        self.traceEventsByTestCase[index] = (
                            events: parsed.events, truncated: parsed.isTruncated
                        )
                        if index == 0 {
                            self.updateJourney(parsed.events, truncated: parsed.isTruncated)
                        }
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

            // Step 4: If all passed, submit to LeetCode
            if allPassed {
                let submissionOutcome = await self.submitToLeetCodeDirect()
                if let console = submissionOutcome.consoleMessage, !console.isEmpty {
                    consoleLogs.append(console)
                }
                if let error = submissionOutcome.errorMessage, !error.isEmpty {
                    errorLogs.append(error)
                }
                if submissionOutcome.didSubmit {
                    await MainActor.run {
                        self.recordSubmission()
                    }
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

    // swiftlint:disable cyclomatic_complexity function_body_length
    private func executeTests(saveSubmission: Bool) {
        clearJourney()
        isRunning = true
        compilationOutput = ""
        errorOutput = ""
        executionLogAnchor = Date()
        showSubmissionTagPrompt = false
        pendingSubmission = nil
        submissionTagInput = ""

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
                        let normalized = self.normalizeOutputForComparison(
                            parsed.cleanOutput,
                            expected: normalizedExpected
                        )
                        updatedTestCases[index].actualOutput = normalized.displayValue
                        if normalizedExpected.isEmpty {
                            updatedTestCases[index].passed = nil
                        } else {
                            updatedTestCases[index].passed = normalized.comparisonValue == normalizedExpected
                        }
                    }
                    if updatedTestCases[index].passed != true {
                        allPassed = false
                    }
                    self.testCases = updatedTestCases
                    if result.isSuccess, !parsed.events.isEmpty {
                        self.traceEventsByTestCase[index] = (
                            events: parsed.events, truncated: parsed.isTruncated
                        )
                        if index == 0 {
                            self.updateJourney(parsed.events, truncated: parsed.isTruncated)
                        }
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
                let submissionOutcome = await self.submitToLeetCodeDirect()
                if let console = submissionOutcome.consoleMessage, !console.isEmpty {
                    consoleLogs.append(console)
                }
                if let error = submissionOutcome.errorMessage, !error.isEmpty {
                    errorLogs.append(error)
                }
                if submissionOutcome.didSubmit {
                    await MainActor.run {
                        self.recordSubmission()
                    }
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
