@testable import FocusApp
import Foundation

final class InMemoryAppStorage: AppStorage {
    private var stored: AppData

    init(initial: AppData = AppData()) {
        stored = initial
    }

    func load() -> AppData {
        stored
    }

    func save(_ data: AppData) {
        stored = data
    }
}

struct FixedDateProvider: DateProviding {
    let date: Date

    func now() -> Date { date }
}

final class StubLeetCodeClient: LeetCodeClientProtocol {
    var validateResult: Result<Bool, Error> = .success(true)
    var solvedSlugsResult: Result<Set<String>, Error> = .success([])
    var contentBySlug: [String: QuestionContent] = [:]
    var delayBySlug: [String: UInt64] = [:]

    func validateUsername(_ username: String) async throws -> Bool {
        try validateResult.get()
    }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> {
        try solvedSlugsResult.get()
    }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        if let delay = delayBySlug[slug] {
            try? await Task.sleep(nanoseconds: delay)
        }
        return contentBySlug[slug]
    }
}

final class StubCodeExecutor: CodeExecuting {
    struct Request {
        let code: String
        let language: ProgrammingLanguage
        let input: String
    }

    var result: ExecutionResult = .failure("Not configured")
    private(set) var requests: [Request] = []

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        requests.append(Request(code: code, language: language, input: input))
        return result
    }

    func cancelExecution() { }
}

final class StubSolutionStore: SolutionProviding, @unchecked Sendable {
    private var solutions: [String: ProblemSolution] = [:]

    func solution(for slug: String) -> ProblemSolution? {
        solutions[slug]
    }

    func allSolutions() -> [ProblemSolution] {
        Array(solutions.values)
    }

    var solutionCount: Int {
        solutions.count
    }

    func addSolution(_ solution: ProblemSolution) {
        solutions[solution.problemSlug] = solution
    }
}
