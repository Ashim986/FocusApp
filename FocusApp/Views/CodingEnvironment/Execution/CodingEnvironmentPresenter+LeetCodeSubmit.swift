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

    private var aiTestCaseTargetCount: Int { 50 }

    func submitToLeetCodeIfAllowed() async -> SubmissionOutcome {
        guard let problem = selectedProblem,
              let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: L10n.Coding.submitMissingProblem
            )
        }

        guard let questionId = problemContent?.questionId else {
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: L10n.Coding.submitMissingQuestionId
            )
        }

        guard interactor.leetCodeAuth() != nil else {
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: L10n.Coding.submitMissingAuth
            )
        }

        let aiGate = await runAITestGate(slug: slug)
        if !aiGate.passed {
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: aiGate.message
            )
        }

        do {
            let result = try await interactor.submitToLeetCode(
                code: code,
                language: language,
                slug: slug,
                questionId: questionId
            )
            let summary = formatSubmissionSummary(result)
            return SubmissionOutcome(
                didSubmit: true,
                consoleMessage: summary,
                errorMessage: result.compileError ?? result.runtimeError
            )
        } catch {
            let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
            return SubmissionOutcome(
                didSubmit: false,
                consoleMessage: nil,
                errorMessage: L10n.Coding.submitFailed(message)
            )
        }
    }

    private func runAITestGate(slug: String) async -> AITestGateResult {
        guard let provider = interactor.testCaseProvider() else {
            return AITestGateResult(
                passed: false,
                message: L10n.Coding.submitMissingAIProvider
            )
        }

        guard let problem = interactor.manifestProblem(for: slug) else {
            return AITestGateResult(
                passed: false,
                message: L10n.Coding.submitMissingManifest
            )
        }

        let meta = LeetCodeMetaData.decode(from: problemContent?.metaData)
        let cached = interactor.cachedAITestCases(for: slug)
        let aiCases: [SolutionTestCase]

        if cached.isEmpty {
            do {
                await MainActor.run {
                    self.compilationOutput = L10n.Coding.submitGeneratingTests
                }
                let inputs = try await provider.generateTestInputs(
                    for: problem,
                    meta: meta,
                    sampleInput: problemContent?.sampleTestCase,
                    exampleInputs: problemContent?.exampleTestcases
                        .components(separatedBy: "\n")
                        .filter { !$0.isEmpty } ?? [],
                    count: aiTestCaseTargetCount
                )

                guard let solutionCode = currentSolution?.sortedApproaches.first?.code,
                      !solutionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return AITestGateResult(
                        passed: false,
                        message: L10n.Coding.submitMissingReferenceSolution
                    )
                }

                aiCases = try await buildAITestCases(
                    inputs: inputs,
                    solutionCode: solutionCode
                )

                let leetCodeNumber = selectedProblem?.leetcodeNumber ?? problem.number
                interactor.saveAITestCases(
                    aiCases,
                    for: slug,
                    leetCodeNumber: leetCodeNumber,
                    questionId: problemContent?.questionId
                )
            } catch {
                let message = (error as? CustomStringConvertible)?.description ?? error.localizedDescription
                return AITestGateResult(
                    passed: false,
                    message: L10n.Coding.submitAiGenerationFailed(message)
                )
            }
        } else {
            aiCases = cached
        }

        await MainActor.run {
            self.compilationOutput = L10n.Coding.submitRunningAiTests(aiCases.count)
        }

        let aiResult = await runAITestCases(aiCases)
        if !aiResult.passed {
            return AITestGateResult(
                passed: false,
                message: L10n.Coding.submitAiTestsFailed(aiResult.failedCount, aiCases.count)
            )
        }

        return AITestGateResult(
            passed: true,
            message: nil
        )
    }

    private func buildAITestCases(
        inputs: [String],
        solutionCode: String
    ) async throws -> [SolutionTestCase] {
        guard !inputs.isEmpty else {
            throw TestCaseGenerationError.invalidResponse("No AI test inputs generated.")
        }

        let wrappedSolution = wrappedCodeForExecution(solutionCode, language: .swift)
        var testCases: [SolutionTestCase] = []
        testCases.reserveCapacity(inputs.count)

        for input in inputs {
            if Task.isCancelled { throw CancellationError() }
            let result = await interactor.executeCode(
                code: wrappedSolution,
                language: .swift,
                input: input
            )
            guard result.isSuccess, result.error.isEmpty else {
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

    private func runAITestCases(_ aiCases: [SolutionTestCase]) async -> (passed: Bool, failedCount: Int) {
        guard !aiCases.isEmpty else { return (false, aiCases.count) }
        let executionCode = wrappedCodeForExecution()
        var failed = 0

        for item in aiCases {
            if Task.isCancelled { break }
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: item.input
            )
            if Task.isCancelled { break }
            if !result.error.isEmpty || result.timedOut || result.wasCancelled {
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
}
