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
        #if os(iOS)
        // On iOS, code runs via LeetCode's interpret_solution API which has its own harness.
        // No wrapping needed — send the raw user code.
        return source
        #else
        guard let meta = LeetCodeMetaData.decode(from: problemContent?.metaData) else { return source }
        return LeetCodeExecutionWrapper.wrap(code: source, language: language, meta: meta)
        #endif
    }

    private func resolveExecutionQuestionId(for slug: String?) async -> String? {
        guard let slug, !slug.isEmpty else { return problemContent?.questionId }
        if let questionId = problemContent?.questionId, !questionId.isEmpty {
            return questionId
        }

        if let cached = problemContentCache[slug]?.content {
            if activeProblemSlug == slug {
                await MainActor.run {
                    self.problemContent = cached
                    self.parseTestCases(from: cached)
                    self.applySnippetIfNeeded(from: cached)
                }
                if let requestID = activeContentRequestID {
                    await ensureProblemDescriptionText(for: cached, slug: slug, requestID: requestID)
                }
            }
            if let questionId = cached.questionId, !questionId.isEmpty {
                return questionId
            }
        }

        do {
            if let fetched = try await interactor.fetchProblemContent(slug: slug) {
                await MainActor.run {
                    self.problemContentCache[slug] = CachedContent(content: fetched, timestamp: Date())
                    if self.activeProblemSlug == slug {
                        self.problemContent = fetched
                        self.parseTestCases(from: fetched)
                        self.applySnippetIfNeeded(from: fetched)
                    }
                }
                if activeProblemSlug == slug, let requestID = activeContentRequestID {
                    await ensureProblemDescriptionText(for: fetched, slug: slug, requestID: requestID)
                }
                if let questionId = fetched.questionId, !questionId.isEmpty {
                    return questionId
                }
            }
        } catch {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .warning,
                    category: .network,
                    title: "Execution metadata fetch failed",
                    message: error.localizedDescription,
                    metadata: ["slug": slug]
                )
            )
        }

        return problemContent?.questionId
    }

    private func executionContextError(slug: String?, questionId: String?) -> String? {
        #if os(iOS)
        guard let slug, !slug.isEmpty else {
            return "No problem selected. Please choose a problem first."
        }
        guard let questionId, !questionId.isEmpty else {
            return "Problem metadata is still loading. Please try Run again in a moment."
        }
        return nil
        #else
        _ = slug
        _ = questionId
        return nil
        #endif
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
            let slug = self.activeProblemSlug
            let questionId = await self.resolveExecutionQuestionId(for: slug)
            if let contextError = self.executionContextError(slug: slug, questionId: questionId) {
                await MainActor.run {
                    self.errorOutput = contextError
                    self.isRunning = false
                }
                return
            }
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: runInput,
                slug: slug,
                questionId: questionId
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

            let executionCode = self.wrappedCodeForExecution()
            let slug = self.activeProblemSlug
            let questionId = await self.resolveExecutionQuestionId(for: slug)
            if let contextError = self.executionContextError(slug: slug, questionId: questionId) {
                await MainActor.run {
                    self.errorOutput = contextError
                    self.isRunning = false
                }
                return
            }
            let hiddenResult = await self.runHiddenTestGate(
                executionCode: executionCode,
                slug: slug,
                questionId: questionId
            )
            guard !Task.isCancelled else { return }

            var consoleLogs: [String] = []
            if hiddenResult.totalCount == 0 {
                await MainActor.run {
                    self.errorOutput = "No hidden test cases available. Please wait for generation."
                    self.isRunning = false
                }
                return
            }

            if hiddenResult.allPassed {
                consoleLogs.append("All \(hiddenResult.totalCount) hidden tests passed!")
                let submissionOutcome = await self.submitToLeetCodeDirect()
                if let console = submissionOutcome.consoleMessage, !console.isEmpty {
                    consoleLogs.append(console)
                }
                if let error = submissionOutcome.errorMessage, !error.isEmpty {
                    await MainActor.run { self.errorOutput = error }
                }
                if submissionOutcome.didSubmit {
                    await MainActor.run { self.recordSubmission() }
                }
            } else {
                // Populate ONLY failed cases into the test panel
                await MainActor.run {
                    self.testCases = hiddenResult.failedCases
                }
                consoleLogs.append(
                    "\(hiddenResult.failedCases.count) of \(hiddenResult.totalCount) hidden tests failed."
                )
            }

            await MainActor.run {
                if !consoleLogs.isEmpty {
                    self.compilationOutput = consoleLogs
                        .joined(separator: "\n\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
                self.isRunning = false
            }
        }
    }

    /// Waits for background hidden test generation to finish, or returns cached tests.
    private func waitForHiddenTests() async -> [SolutionTestCase] {
        // If already available, return immediately
        if !hiddenTestCases.isEmpty { return hiddenTestCases }

        if hiddenTestGenerationTask == nil {
            startHiddenTestGeneration()
        }

        // Wait for background generation task to finish
        if let task = hiddenTestGenerationTask {
            await MainActor.run {
                self.compilationOutput = "Waiting for hidden test generation…"
            }
            _ = await task.result
        }

        return hiddenTestCases
    }

    struct HiddenTestResult {
        let allPassed: Bool
        let failedCases: [TestCase]
        let totalCount: Int
    }

    /// Runs user code against all hidden test cases. Returns pass/fail status and failed cases.
    func runHiddenTestGate(
        executionCode: String,
        slug: String?,
        questionId: String?
    ) async -> HiddenTestResult {
        let aiCases = await waitForHiddenTests()
        guard !aiCases.isEmpty else {
            return HiddenTestResult(allPassed: true, failedCases: [], totalCount: 0)
        }

        await MainActor.run { self.hiddenTestsHaveFailures = false }
        var failedCases: [TestCase] = []

        for (index, item) in aiCases.enumerated() {
            if Task.isCancelled { break }
            let passed = index - failedCases.count
            let failed = failedCases.count
            await MainActor.run {
                self.compilationOutput =
                    "Hidden test \(index + 1)/\(aiCases.count)  ✓ \(passed)  ✗ \(failed)"
                self.hiddenTestsHaveFailures = failed > 0
            }
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: item.input,
                slug: slug,
                questionId: questionId
            )
            if Task.isCancelled { break }

            let parsed = parseTraceOutput(result.output)

            if result.exitCode != 0 || result.timedOut || result.wasCancelled {
                var failedCase = TestCase(input: item.input, expectedOutput: item.expectedOutput)
                if result.timedOut {
                    failedCase.actualOutput = "Timed out"
                } else if result.wasCancelled {
                    failedCase.actualOutput = "Stopped"
                } else {
                    failedCase.actualOutput = "Error: \(result.error)"
                }
                failedCase.passed = false
                failedCases.append(failedCase)
                continue
            }

            let normalizedExpected = item.expectedOutput
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let normalized = await MainActor.run {
                self.normalizeOutputForComparison(
                    parsed.cleanOutput,
                    expected: normalizedExpected
                )
            }

            if !normalizedExpected.isEmpty,
               !self.outputMatches(
                   normalized.comparisonValue,
                   expected: normalizedExpected,
                   orderMatters: item.orderMatters
               ) {
                var failedCase = TestCase(input: item.input, expectedOutput: item.expectedOutput)
                failedCase.actualOutput = normalized.displayValue
                failedCase.passed = false
                failedCases.append(failedCase)
            }
        }

        return HiddenTestResult(
            allPassed: failedCases.isEmpty,
            failedCases: failedCases,
            totalCount: aiCases.count
        )
    }

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
            let slug = self.activeProblemSlug
            let questionId = await self.resolveExecutionQuestionId(for: slug)
            if let contextError = self.executionContextError(slug: slug, questionId: questionId) {
                await MainActor.run {
                    self.errorOutput = contextError
                    self.isRunning = false
                }
                return
            }
            var allPassed = true

            for index in updatedTestCases.indices {
                if Task.isCancelled { break }
                let testCase = updatedTestCases[index]
                let result = await interactor.executeCode(
                    code: executionCode,
                    language: language,
                    input: testCase.input,
                    slug: slug,
                    questionId: questionId
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
                            updatedTestCases[index].passed = self.outputMatches(
                                normalized.comparisonValue,
                                expected: normalizedExpected
                            )
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
                // Run hidden tests before submitting to LeetCode
                let hiddenResult = await self.runHiddenTestGate(
                    executionCode: executionCode,
                    slug: slug,
                    questionId: questionId
                )
                if hiddenResult.allPassed {
                    consoleLogs.append("All \(hiddenResult.totalCount) hidden tests passed!")
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
                } else {
                    // Add failed hidden tests to the test panel
                    await MainActor.run {
                        self.testCases = updatedTestCases + hiddenResult.failedCases
                    }
                    consoleLogs.append(
                        "\(hiddenResult.failedCases.count) of \(hiddenResult.totalCount) hidden tests failed."
                    )
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
