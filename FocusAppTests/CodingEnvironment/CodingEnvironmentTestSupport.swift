@testable import FocusApp
import Foundation
import XCTest

@MainActor
func makeCodingPresenter() -> CodingEnvironmentPresenter {
    CodingEnvironmentPresenter(interactor: makeCodingInteractor())
}

@MainActor
func makeCodingInteractor() -> CodingEnvironmentInteractor {
    let start = makeDate(year: 2026, month: 2, day: 3)
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: start),
        dateProvider: FixedDateProvider(date: start)
    )
    let fakeExecutor = FakeRequestExecutor()
    let submissionService = LeetCodeSubmissionService(executor: fakeExecutor)
    return CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: FakeLeetCodeClient(),
        executionService: FakeCodeExecutor(),
        solutionStore: FakeSolutionStore(),
        submissionService: submissionService
    )
}

func functionMetaJSON(name: String, params: [(String, String)], returnType: String) -> String {
    let paramsJSON = params.map { "{\"name\":\"\($0.0)\",\"type\":\"\($0.1)\"}" }.joined(separator: ",")
    return "{\"name\":\"\(name)\",\"params\":[\(paramsJSON)],\"return\":{\"type\":\"\(returnType)\"}}"
}

func problemWithSlug(
    _ slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> Problem {
    for day in dsaPlan {
        for problem in day.problems where LeetCodeSlugExtractor.extractSlug(from: problem.url) == slug {
            return problem
        }
    }
    XCTFail("Missing problem for slug \(slug)", file: file, line: line)
    return dsaPlan.first?.problems.first ?? Problem(
        name: slug,
        difficulty: .easy,
        url: "https://leetcode.com/problems/\(slug)/"
    )
}

struct ProblemLocation {
    let problem: Problem
    let dayId: Int
    let index: Int
}

func problemLocation(
    for slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> ProblemLocation {
    for day in dsaPlan {
        if let index = day.problems.firstIndex(
            where: { LeetCodeSlugExtractor.extractSlug(from: $0.url) == slug }
        ) {
            return ProblemLocation(problem: day.problems[index], dayId: day.id, index: index)
        }
    }
    XCTFail("Missing problem location for slug \(slug)", file: file, line: line)
    let fallback = problemWithSlug(slug, file: file, line: line)
    return ProblemLocation(problem: fallback, dayId: 1, index: 0)
}

// MARK: - Presenter Helpers

struct ExecutionRequest {
    let code: String
    let language: ProgrammingLanguage
    let input: String
}

struct CodingHarness {
    let presenter: CodingEnvironmentPresenter
    let store: AppStateStore
    let executor: QueueCodeExecutor
}

final class QueueCodeExecutor: CodeExecuting {
    var requests: [ExecutionRequest] = []
    var results: [ExecutionResult] = []
    var cancelCalled = false

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        requests.append(ExecutionRequest(code: code, language: language, input: input))
        if results.isEmpty {
            return ExecutionResult.failure("Not configured")
        }
        return results.removeFirst()
    }

    func cancelExecution() {
        cancelCalled = true
    }
}

struct ThrowingLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        throw TestError()
    }
}

@MainActor
func makeHarness(
    executor: QueueCodeExecutor = QueueCodeExecutor(),
    client: LeetCodeClientProtocol = FakeLeetCodeClient(),
    logger: DebugLogStore? = nil
) -> CodingHarness {
    let start = makeDate(year: 2026, month: 2, day: 3)
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: start),
        dateProvider: FixedDateProvider(date: start)
    )
    let interactor = CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: client,
        executionService: executor,
        solutionStore: FakeSolutionStore(),
        submissionService: LeetCodeSubmissionService(executor: FakeRequestExecutor())
    )
    let presenter = CodingEnvironmentPresenter(interactor: interactor, logger: logger)
    return CodingHarness(presenter: presenter, store: store, executor: executor)
}

@MainActor
func waitFor(_ condition: @escaping () -> Bool, timeout: TimeInterval = 1.0) async -> Bool {
    let start = Date()
    while Date().timeIntervalSince(start) < timeout {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
    return condition()
}
