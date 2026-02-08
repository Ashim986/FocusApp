import Foundation

@MainActor
final class CodingEnvironmentInteractor {
    private let appStore: AppStateStore
    private let leetCodeClient: LeetCodeClientProtocol
    private let executionService: CodeExecuting
    private let solutionStore: SolutionProviding
    private let submissionService: LeetCodeSubmissionService
    private let manifestStore: ProblemManifestStore
    private let aiTestCaseStore: AITestCaseStore

    init(
        appStore: AppStateStore,
        leetCodeClient: LeetCodeClientProtocol,
        executionService: CodeExecuting,
        solutionStore: SolutionProviding,
        submissionService: LeetCodeSubmissionService,
        manifestStore: ProblemManifestStore = .shared,
        aiTestCaseStore: AITestCaseStore = AITestCaseStore()
    ) {
        self.appStore = appStore
        self.leetCodeClient = leetCodeClient
        self.executionService = executionService
        self.solutionStore = solutionStore
        self.submissionService = submissionService
        self.manifestStore = manifestStore
        self.aiTestCaseStore = aiTestCaseStore
    }

    func todaysProblems() -> [Problem] {
        let dayNum = appStore.currentDayNumber()
        return dsaPlan.first(where: { $0.id == dayNum })?.problems ?? []
    }

    func currentDayNumber() -> Int {
        appStore.currentDayNumber()
    }

    func todaysTopic() -> String {
        appStore.todaysTopic()
    }

    func isProblemCompleted(day: Int, problemIndex: Int) -> Bool {
        appStore.isProblemCompleted(day: day, problemIndex: problemIndex)
    }

    func solutionCode(for key: String) -> String? {
        appStore.solutionCode(for: key)
    }

    func saveSolution(code: String, for key: String) {
        appStore.saveSolution(code: code, for: key)
    }

    func submissions(for key: String) -> [CodeSubmission] {
        appStore.submissions(for: key)
    }

    func addSubmission(code: String, language: ProgrammingLanguage, for key: String) {
        appStore.addSubmission(code: code, language: language, algorithmTag: nil, for: key)
    }

    func addSubmission(code: String, language: ProgrammingLanguage, algorithmTag: String?, for key: String) {
        appStore.addSubmission(code: code, language: language, algorithmTag: algorithmTag, for: key)
    }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        try await leetCodeClient.fetchProblemContent(slug: slug)
    }

    func executeCode(
        code: String,
        language: ProgrammingLanguage,
        input: String,
        slug: String? = nil,
        questionId: String? = nil
    ) async -> ExecutionResult {
        #if os(iOS)
        if let leetCodeService = executionService as? LeetCodeExecutionService {
            leetCodeService.problemSlug = slug
            leetCodeService.questionId = questionId
            leetCodeService.authSession = appStore.leetCodeAuth()
        }
        #endif
        return await executionService.execute(code: code, language: language, input: input)
    }

    func cancelExecution() {
        executionService.cancelExecution()
    }

    // MARK: - Solutions

    func solution(for problem: Problem) -> ProblemSolution? {
        guard let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            return nil
        }
        return solutionStore.solution(for: slug)
    }

    // MARK: - LeetCode Auth + Submission

    func leetCodeAuth() -> LeetCodeAuthSession? {
        appStore.leetCodeAuth()
    }

    func updateLeetCodeAuth(_ auth: LeetCodeAuthSession) {
        appStore.updateLeetCodeAuth(auth)
    }

    func submitToLeetCode(
        code: String,
        language: ProgrammingLanguage,
        slug: String,
        questionId: String
    ) async throws -> LeetCodeSubmissionCheck {
        guard let auth = appStore.leetCodeAuth() else {
            throw LeetCodeSubmissionError.missingAuth
        }
        return try await submissionService.submit(
            code: code,
            languageSlug: language.langSlug,
            slug: slug,
            questionId: questionId,
            auth: auth
        )
    }

    // MARK: - AI Test Cases

    func testCaseProvider() -> (any TestCaseAIProviding)? {
        SolutionAIServiceFactory.makeTestCaseProvider(from: appStore.data)
    }

    struct AIProviderDebugInfo {
        let kind: String
        let apiKeyLength: Int
        let model: String
    }

    func aiProviderDebugInfo() -> AIProviderDebugInfo {
        let data = appStore.data
        return AIProviderDebugInfo(
            kind: data.aiProviderKind,
            apiKeyLength: data.aiProviderApiKey.trimmingCharacters(in: .whitespacesAndNewlines).count,
            model: data.aiProviderModel
        )
    }

    func manifestProblem(for slug: String) -> ManifestProblem? {
        manifestStore.problem(for: slug)
    }

    func cachedAITestCases(for slug: String) -> [SolutionTestCase] {
        aiTestCaseStore.testCases(for: slug)
    }

    func saveAITestCases(
        _ testCases: [SolutionTestCase],
        for slug: String,
        leetCodeNumber: Int?,
        questionId: String?
    ) {
        aiTestCaseStore.save(
            testCases: testCases,
            for: slug,
            leetCodeNumber: leetCodeNumber,
            questionId: questionId
        )
    }
}
