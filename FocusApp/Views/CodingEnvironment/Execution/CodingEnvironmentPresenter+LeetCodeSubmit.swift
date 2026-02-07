import Foundation

extension CodingEnvironmentPresenter {
    struct SubmissionOutcome {
        let didSubmit: Bool
        let consoleMessage: String?
        let errorMessage: String?
    }

    private struct AITestGateResult {
        let passed: Bool
        let message: String?
    }

    private struct SubmissionContext {
        let slug: String
        let questionId: String
        let content: QuestionContent
    }

    private enum SubmissionContextResult {
        case ready(SubmissionContext)
        case blocked(SubmissionOutcome)
    }

    private enum AITestCaseResolution {
        case success([SolutionTestCase])
        case failure(AITestGateResult)
    }

    private var aiTestCaseTargetCount: Int { 50 }

    func submitToLeetCodeIfAllowed() async -> SubmissionOutcome {
        switch await resolveSubmissionContext() {
        case .blocked(let outcome):
            return outcome
        case .ready(let context):
            return await submitWithContext(context)
        }
    }

    private func runAITestGate(slug: String, content: QuestionContent) async -> AITestGateResult {
        guard let provider = interactor.testCaseProvider() else {
            return gateFailure(
                title: "AI tests blocked",
                message: missingProviderMessage(slug: slug),
                errorMessage: L10n.Coding.submitMissingAIProvider,
                slug: slug
            )
        }

        guard let problem = interactor.manifestProblem(for: slug) else {
            return gateFailure(
                title: "AI tests blocked",
                message: "Missing problem manifest.",
                errorMessage: L10n.Coding.submitMissingManifest,
                slug: slug
            )
        }

        guard let meta = LeetCodeMetaData.decode(from: content.metaData) else {
            return gateFailure(
                title: "AI tests blocked",
                message: "Missing problem metadata.",
                errorMessage: L10n.Coding.submitMissingManifest,
                slug: slug
            )
        }
        let resolution = await resolveAITestCases(
            slug: slug,
            provider: provider,
            problem: problem,
            meta: meta,
            content: content
        )
        guard case .success(let aiCases) = resolution else {
            if case .failure(let result) = resolution { return result }
            return gateFailure(
                title: "AI tests failed",
                message: "Unknown AI test failure.",
                errorMessage: L10n.Coding.submitAiTestsFailed(0, 0),
                slug: slug,
                level: .error
            )
        }

        await MainActor.run {
            self.compilationOutput = L10n.Coding.submitRunningAiTests(aiCases.count)
        }

        let aiResult = await runAITestCases(aiCases)
        if !aiResult.passed {
            logSubmissionEvent(
                level: .warning,
                title: "AI tests failed",
                message: "AI tests did not pass.",
                metadata: [
                    "slug": slug,
                    "failed": "\(aiResult.failedCount)",
                    "total": "\(aiCases.count)"
                ]
            )
            return AITestGateResult(
                passed: false,
                message: L10n.Coding.submitAiTestsFailed(aiResult.failedCount, aiCases.count)
            )
        }

        logSubmissionEvent(
            title: "AI tests passed",
            message: "AI tests passed.",
            metadata: [
                "slug": slug,
                "count": "\(aiCases.count)"
            ]
        )
        return AITestGateResult(
            passed: true,
            message: nil
        )
    }

    private func buildAITestCases(
        inputs: [String],
        solutionCode: String,
        slug: String
    ) async throws -> [SolutionTestCase] {
        guard !inputs.isEmpty else {
            throw TestCaseGenerationError.invalidResponse("No AI test inputs generated.")
        }

        let preparedSolution = prepareReferenceSolutionCode(solutionCode)
        let wrappedSolution = wrappedCodeForExecution(preparedSolution, language: .swift)
        var testCases: [SolutionTestCase] = []
        testCases.reserveCapacity(inputs.count)

        for (index, input) in inputs.enumerated() {
            if Task.isCancelled { throw CancellationError() }
            await MainActor.run {
                self.compilationOutput = "Building reference test \(index + 1) of \(inputs.count)…"
            }
            let result = await interactor.executeCode(
                code: wrappedSolution,
                language: .swift,
                input: input
            )
            guard result.exitCode == 0, !result.timedOut, !result.wasCancelled else {
                let errorDetail = result.timedOut ? "Timed out." :
                    result.wasCancelled ? "Cancelled." :
                    result.error.isEmpty ? "Exit code \(result.exitCode)." : result.error
                logSubmissionEvent(
                    level: .error,
                    title: "Reference solution failed",
                    message: errorDetail,
                    metadata: ["slug": slug, "exitCode": "\(result.exitCode)"]
                )
                throw TestCaseGenerationError.invalidResponse("Reference solution failed to run.")
            }
            let parsed = parseTraceOutput(result.output)
            let expected = parsed.cleanOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !expected.isEmpty else {
                throw TestCaseGenerationError.invalidResponse("Reference solution produced empty output.")
            }
            testCases.append(
                SolutionTestCase(
                    input: input,
                    expectedOutput: expected,
                    explanation: nil
                )
            )
        }

        return testCases
    }

    private func prepareReferenceSolutionCode(_ code: String) -> String {
        if code.contains("class Solution") || code.contains("struct Solution") {
            return code
        }

        let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var imports: [String] = []
        var bodyLines: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("import ") {
                imports.append(line)
            } else {
                bodyLines.append(line)
            }
        }

        let indentedBody = bodyLines.map { line in
            line.isEmpty ? "" : "    \(line)"
        }.joined(separator: "\n")

        let importBlock = imports.isEmpty ? "" : imports.joined(separator: "\n") + "\n\n"
        return """
        \(importBlock)class Solution {
        \(indentedBody)
        }
        """
    }

    private func runAITestCases(_ aiCases: [SolutionTestCase]) async -> (passed: Bool, failedCount: Int) {
        guard !aiCases.isEmpty else { return (false, aiCases.count) }
        let executionCode = wrappedCodeForExecution()
        var failed = 0

        for (index, item) in aiCases.enumerated() {
            if Task.isCancelled { break }
            await MainActor.run {
                self.compilationOutput = "Running AI test \(index + 1) of \(aiCases.count)…"
            }
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: item.input
            )
            if Task.isCancelled { break }
            if result.exitCode != 0 || result.timedOut || result.wasCancelled {
                failed += 1
                continue
            }
            let parsed = parseTraceOutput(result.output)
            let normalized = normalizeOutputForComparison(
                parsed.cleanOutput,
                expected: item.expectedOutput
            )
            if normalized.comparisonValue != item.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines) {
                failed += 1
            }
        }

        return (failed == 0, failed)
    }

    private func formatSubmissionSummary(_ result: LeetCodeSubmissionCheck) -> String {
        let status = result.statusMsg ?? "Submitted"
        let total = result.totalTestcases ?? 0
        let correct = result.totalCorrect ?? 0
        if total > 0 {
            return L10n.Coding.submitResultWithCounts(status, correct, total)
        }
        return L10n.Coding.submitResult(status)
    }

    private func logSubmissionEvent(
        level: DebugLogLevel = .info,
        title: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        logger?.recordAsync(
            DebugLogEntry(
                level: level,
                category: .network,
                title: title,
                message: message,
                metadata: metadata
            )
        )
    }

    private func resolveSubmissionContext() async -> SubmissionContextResult {
        guard let problem = selectedProblem,
              let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            return .blocked(
                submissionBlocked(
                    reason: "Missing problem slug.",
                    errorMessage: L10n.Coding.submitMissingProblem
                )
            )
        }

        guard let content = await ensureProblemContent(slug: slug) else {
            return .blocked(
                submissionBlocked(
                    reason: "Missing problem metadata.",
                    errorMessage: L10n.Coding.submitMissingManifest,
                    slug: slug
                )
            )
        }

        guard let questionId = content.questionId else {
            return .blocked(
                submissionBlocked(
                    reason: "Missing question id.",
                    errorMessage: L10n.Coding.submitMissingQuestionId,
                    slug: slug
                )
            )
        }

        guard interactor.leetCodeAuth() != nil else {
            requestLeetCodeLogin()
            return .blocked(
                submissionBlocked(
                    reason: "Missing LeetCode login.",
                    errorMessage: L10n.Coding.submitMissingAuth,
                    slug: slug
                )
            )
        }

        return .ready(SubmissionContext(slug: slug, questionId: questionId, content: content))
    }

    private func submitWithContext(_ context: SubmissionContext) async -> SubmissionOutcome {
        logSubmissionEvent(
            title: "Submit requested",
            message: "Preparing LeetCode submission.",
            metadata: [
                "slug": context.slug,
                "language": language.rawValue,
                "question_id": context.questionId
            ]
        )

        let aiGate = await runAITestGate(slug: context.slug, content: context.content)
        guard aiGate.passed else {
            return submissionBlocked(
                reason: aiGate.message ?? "AI tests failed.",
                errorMessage: aiGate.message ?? "AI tests failed.",
                slug: context.slug
            )
        }

        logSubmissionEvent(
            title: "Submitting to LeetCode",
            message: "Submitting code.",
            metadata: [
                "slug": context.slug,
                "language": language.rawValue
            ]
        )

        do {
            let result = try await interactor.submitToLeetCode(
                code: code,
                language: language,
                slug: context.slug,
                questionId: context.questionId
            )
            logSubmissionEvent(
                title: "Submission complete",
                message: result.statusMsg ?? "Submitted",
                metadata: [
                    "slug": context.slug,
                    "status": "\(result.statusCode ?? 0)",
                    "correct": "\(result.totalCorrect ?? 0)",
                    "total": "\(result.totalTestcases ?? 0)"
                ]
            )
            let summary = formatSubmissionSummary(result)
            return SubmissionOutcome(
                didSubmit: true,
                consoleMessage: summary,
                errorMessage: result.compileError ?? result.runtimeError
            )
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            logSubmissionEvent(
                level: .error,
                title: "Submission failed",
                message: message,
                metadata: ["slug": context.slug]
            )
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: L10n.Coding.submitFailed(message)
            )
        }
    }

    private func submissionBlocked(
        reason: String,
        errorMessage: String,
        slug: String? = nil
    ) -> SubmissionOutcome {
        var metadata: [String: String] = [:]
        if let slug {
            metadata["slug"] = slug
        }
        logSubmissionEvent(
            level: .warning,
            title: "Submit blocked",
            message: reason,
            metadata: metadata
        )
        return SubmissionOutcome(
            didSubmit: false,
            consoleMessage: nil,
            errorMessage: errorMessage
        )
    }

    private func requestLeetCodeLogin() {
        showLeetCodeLogin = true
    }

    private func gateFailure(
        title: String,
        message: String,
        errorMessage: String,
        slug: String,
        level: DebugLogLevel = .warning
    ) -> AITestGateResult {
        logSubmissionEvent(
            level: level,
            title: title,
            message: message,
            metadata: ["slug": slug]
        )
        return AITestGateResult(
            passed: false,
            message: errorMessage
        )
    }

    private func resolveAITestCases(
        slug: String,
        provider: any TestCaseAIProviding,
        problem: ManifestProblem,
        meta: LeetCodeMetaData,
        content: QuestionContent
    ) async -> AITestCaseResolution {
        let cached = interactor.cachedAITestCases(for: slug)
        if !cached.isEmpty {
            logSubmissionEvent(
                title: "AI tests cached",
                message: "Using cached AI tests.",
                metadata: [
                    "slug": slug,
                    "count": "\(cached.count)"
                ]
            )
            return .success(cached)
        }

        do {
            logSubmissionEvent(
                title: "AI tests generating",
                message: "Generating AI test inputs.",
                metadata: [
                    "slug": slug,
                    "count": "\(aiTestCaseTargetCount)"
                ]
            )
            await MainActor.run {
                self.compilationOutput = L10n.Coding.submitGeneratingTests
            }

            let inputs = try await provider.generateTestInputs(
                for: problem,
                meta: meta,
                sampleInput: content.sampleTestCase,
                exampleInputs: content.exampleTestcases
                    .components(separatedBy: "\n")
                    .filter { !$0.isEmpty } ?? [],
                count: aiTestCaseTargetCount
            )

            guard let solutionCode = currentSolution?.sortedApproaches.first?.code,
                  !solutionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure(
                    gateFailure(
                        title: "AI tests blocked",
                        message: "Missing reference solution.",
                        errorMessage: L10n.Coding.submitMissingReferenceSolution,
                        slug: slug
                    )
                )
            }

            let aiCases = try await buildAITestCases(
                inputs: inputs,
                solutionCode: solutionCode,
                slug: slug
            )

            let leetCodeNumber = selectedProblem?.leetcodeNumber ?? problem.number
            interactor.saveAITestCases(
                aiCases,
                for: slug,
                leetCodeNumber: leetCodeNumber,
                questionId: content.questionId
            )
            logSubmissionEvent(
                title: "AI tests generated",
                message: "Generated AI tests.",
                metadata: [
                    "slug": slug,
                    "count": "\(aiCases.count)"
                ]
            )
            return .success(aiCases)
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            logSubmissionEvent(
                level: .error,
                title: "AI tests failed",
                message: message,
                metadata: ["slug": slug]
            )
            return .failure(
                AITestGateResult(
                    passed: false,
                    message: L10n.Coding.submitAiGenerationFailed(message)
                )
            )
        }
    }

    private func ensureProblemContent(slug: String) async -> QuestionContent? {
        if let content = problemContent, content.metaData != nil {
            return content
        }
        logSubmissionEvent(
            title: "Loading problem metadata",
            message: "Fetching LeetCode metadata.",
            metadata: ["slug": slug]
        )
        do {
            let fetched = try await interactor.fetchProblemContent(slug: slug)
            if let fetched {
                await MainActor.run {
                    self.problemContent = fetched
                }
            }
            return fetched ?? problemContent
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            logSubmissionEvent(
                level: .error,
                title: "Metadata fetch failed",
                message: message,
                metadata: ["slug": slug]
            )
            return problemContent
        }
    }

    private func missingProviderMessage(slug: String) -> String {
        let info = interactor.aiProviderDebugInfo()
        logSubmissionEvent(
            level: .warning,
            title: "AI provider details",
            message: "AI provider missing.",
            metadata: [
                "slug": slug,
                "kind": info.kind,
                "api_key_length": "\(info.apiKeyLength)",
                "model": info.model
            ]
        )
        return "Missing AI provider."
    }

    // MARK: - Panel-based AI test flow

    /// Resolves AI test cases (cached or generated) without running the user's code against them.
    /// Returns the test cases so the caller can populate the test panel and run locally.
    func resolveAITestCasesForPanel() async -> [SolutionTestCase] {
        guard let problem = selectedProblem,
              let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            await MainActor.run { self.errorOutput = L10n.Coding.submitMissingProblem }
            return []
        }

        guard let content = await ensureProblemContent(slug: slug) else {
            await MainActor.run { self.errorOutput = L10n.Coding.submitMissingManifest }
            return []
        }

        guard let provider = interactor.testCaseProvider() else {
            await MainActor.run { self.errorOutput = L10n.Coding.submitMissingAIProvider }
            return []
        }

        guard let manifestProblem = interactor.manifestProblem(for: slug) else {
            await MainActor.run { self.errorOutput = L10n.Coding.submitMissingManifest }
            return []
        }

        guard let meta = LeetCodeMetaData.decode(from: content.metaData) else {
            await MainActor.run { self.errorOutput = L10n.Coding.submitMissingManifest }
            return []
        }

        // Check cache first
        let cached = interactor.cachedAITestCases(for: slug)
        if !cached.isEmpty {
            logSubmissionEvent(
                title: "AI tests cached",
                message: "Using cached AI tests for panel.",
                metadata: ["slug": slug, "count": "\(cached.count)"]
            )
            return cached
        }

        // Generate new test cases
        do {
            await MainActor.run {
                self.compilationOutput = L10n.Coding.submitGeneratingTests
            }

            let inputs = try await provider.generateTestInputs(
                for: manifestProblem,
                meta: meta,
                sampleInput: content.sampleTestCase,
                exampleInputs: content.exampleTestcases
                    .components(separatedBy: "\n")
                    .filter { !$0.isEmpty } ?? [],
                count: aiTestCaseTargetCount
            )

            guard let solutionCode = currentSolution?.sortedApproaches.first?.code,
                  !solutionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                await MainActor.run { self.errorOutput = L10n.Coding.submitMissingReferenceSolution }
                return []
            }

            let aiCases = try await buildAITestCases(
                inputs: inputs,
                solutionCode: solutionCode,
                slug: slug
            )

            let leetCodeNumber = selectedProblem?.leetcodeNumber ?? manifestProblem.number
            interactor.saveAITestCases(
                aiCases,
                for: slug,
                leetCodeNumber: leetCodeNumber,
                questionId: content.questionId
            )

            logSubmissionEvent(
                title: "AI tests generated",
                message: "Generated AI tests for panel.",
                metadata: ["slug": slug, "count": "\(aiCases.count)"]
            )
            return aiCases
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            await MainActor.run { self.errorOutput = L10n.Coding.submitAiGenerationFailed(message) }
            return []
        }
    }

    /// Submits directly to LeetCode (skipping the AI gate, which was already done via panel tests).
    func submitToLeetCodeDirect() async -> SubmissionOutcome {
        switch await resolveSubmissionContext() {
        case .blocked(let outcome):
            return outcome
        case .ready(let context):
            logSubmissionEvent(
                title: "Submitting to LeetCode",
                message: "All AI tests passed. Submitting code.",
                metadata: [
                    "slug": context.slug,
                    "language": language.rawValue
                ]
            )

            await MainActor.run {
                self.compilationOutput = "Submitting to LeetCode…"
            }

            do {
                let result = try await interactor.submitToLeetCode(
                    code: code,
                    language: language,
                    slug: context.slug,
                    questionId: context.questionId
                )
                logSubmissionEvent(
                    title: "Submission complete",
                    message: result.statusMsg ?? "Submitted",
                    metadata: [
                        "slug": context.slug,
                        "status": "\(result.statusCode ?? 0)",
                        "correct": "\(result.totalCorrect ?? 0)",
                        "total": "\(result.totalTestcases ?? 0)"
                    ]
                )
                let summary = formatSubmissionSummary(result)
                return SubmissionOutcome(
                    didSubmit: true,
                    consoleMessage: summary,
                    errorMessage: result.compileError ?? result.runtimeError
                )
            } catch {
                let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
                logSubmissionEvent(
                    level: .error,
                    title: "Submission failed",
                    message: message,
                    metadata: ["slug": context.slug]
                )
                return SubmissionOutcome(
                    didSubmit: false,
                    consoleMessage: nil,
                    errorMessage: L10n.Coding.submitFailed(message)
                )
            }
        }
    }
}
