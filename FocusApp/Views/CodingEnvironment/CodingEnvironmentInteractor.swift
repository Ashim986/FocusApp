import Foundation

@MainActor
final class CodingEnvironmentInteractor {
    private let appStore: AppStateStore
    private let leetCodeClient: LeetCodeClientProtocol
    private let executionService: CodeExecuting

    init(
        appStore: AppStateStore,
        leetCodeClient: LeetCodeClientProtocol,
        executionService: CodeExecuting
    ) {
        self.appStore = appStore
        self.leetCodeClient = leetCodeClient
        self.executionService = executionService
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

    func executeCode(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        await executionService.execute(code: code, language: language, input: input)
    }

    func cancelExecution() {
        executionService.cancelExecution()
    }
}
