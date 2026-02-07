import Foundation

extension CodingEnvironmentPresenter {
    struct SubmissionOutcome {
        let didSubmit: Bool
        let consoleMessage: String?
        let errorMessage: String?
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

    private var aiTestCaseTargetCount: Int { 50 }

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

    // MARK: - Background hidden test generation

    /// Starts background generation of hidden test cases when a problem is selected.
    /// Uses cached test cases if available, otherwise generates via AI + reference solution.
    func startHiddenTestGeneration() {
        hiddenTestGenerationTask?.cancel()
        hiddenTestGenerationTask = Task { [weak self] in
            guard let self else { return }
            await self.generateHiddenTestCases()
        }
    }

    private struct HiddenTestDependencies {
        let slug: String
        let content: QuestionContent
        let provider: any TestCaseAIProviding
        let manifestProblem: ManifestProblem
        let meta: LeetCodeMetaData
    }

    private func resolveHiddenTestDependencies() async -> HiddenTestDependencies? {
        guard let problem = selectedProblem,
              let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
              let content = await ensureProblemContent(slug: slug),
              let provider = interactor.testCaseProvider(),
              let manifestProblem = interactor.manifestProblem(for: slug),
              let meta = LeetCodeMetaData.decode(from: content.metaData) else {
            return nil
        }
        return HiddenTestDependencies(
            slug: slug,
            content: content,
            provider: provider,
            manifestProblem: manifestProblem,
            meta: meta
        )
    }

    private func generateHiddenTestCases() async {
        guard let problem = selectedProblem,
              let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            return
        }

        // Check cache first
        let cached = interactor.cachedAITestCases(for: slug)
        if !cached.isEmpty {
            await MainActor.run { self.hiddenTestCases = cached }
            logSubmissionEvent(
                title: "Hidden tests cached",
                message: "Loaded \(cached.count) cached hidden tests.",
                metadata: ["slug": slug, "count": "\(cached.count)"]
            )
            return
        }

        await MainActor.run { self.isGeneratingHiddenTests = true }
        defer { Task { @MainActor in self.isGeneratingHiddenTests = false } }

        guard let deps = await resolveHiddenTestDependencies(),
              !Task.isCancelled else {
            return
        }

        do {
            let aiCases = try await buildHiddenTestsFromDeps(deps)
            guard !Task.isCancelled else { return }

            let leetCodeNumber = problem.leetcodeNumber ?? deps.manifestProblem.number
            interactor.saveAITestCases(
                aiCases,
                for: slug,
                leetCodeNumber: leetCodeNumber,
                questionId: deps.content.questionId
            )

            await MainActor.run { self.hiddenTestCases = aiCases }
            logSubmissionEvent(
                title: "Hidden tests generated",
                message: "Generated \(aiCases.count) hidden tests in background.",
                metadata: ["slug": slug, "count": "\(aiCases.count)"]
            )
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            logSubmissionEvent(
                level: .warning,
                title: "Hidden test generation failed",
                message: message,
                metadata: ["slug": slug]
            )
        }
    }

    private func buildHiddenTestsFromDeps(_ deps: HiddenTestDependencies) async throws -> [SolutionTestCase] {
        let testCases = try await deps.provider.generateTestCases(
            for: deps.manifestProblem,
            meta: deps.meta,
            sampleInput: deps.content.sampleTestCase,
            exampleInputs: deps.content.exampleTestcases
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty },
            count: aiTestCaseTargetCount
        )

        guard !Task.isCancelled else { throw CancellationError() }
        guard !testCases.isEmpty else {
            throw TestCaseGenerationError.invalidResponse("AI returned no test cases.")
        }

        return testCases
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
