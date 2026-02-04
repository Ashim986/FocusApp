@testable import FocusApp
import XCTest

final class CodingEnvironmentInteractorTests: XCTestCase {
    @MainActor
    func testTodaysProblemsReturnsCorrectProblems() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        let problems = interactor.todaysProblems()

        XCTAssertEqual(problems.count, 5)
        XCTAssertEqual(problems[0].name, "Reverse Linked List")
    }

    @MainActor
    func testIsProblemCompletedDelegatesToAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        XCTAssertFalse(interactor.isProblemCompleted(day: 1, problemIndex: 0))

        store.toggleProblem(day: 1, problemIndex: 0)

        XCTAssertTrue(interactor.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testSolutionCodeReturnsFromAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        let key = "reverse-linked-list|swift"
        store.saveSolution(code: "let x = 1", for: key)

        XCTAssertEqual(interactor.solutionCode(for: key), "let x = 1")
    }

    @MainActor
    func testSaveSolutionPersistsToAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        let key = "reverse-linked-list|swift"
        interactor.saveSolution(code: "func test() {}", for: key)

        XCTAssertEqual(store.solutionCode(for: key), "func test() {}")
    }

    @MainActor
    func testFetchProblemContentDelegatesToClient() async throws {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.contentBySlug["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "Description",
            exampleTestcases: "1,2,3",
            sampleTestCase: "1,2,3",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution {}"],
            metaData: nil
        )
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        let content = try await interactor.fetchProblemContent(slug: "reverse-linked-list")

        XCTAssertNotNil(content)
        XCTAssertEqual(content?.title, "Reverse Linked List")
    }

    @MainActor
    func testExecuteCodeDelegatesToExecutionService() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        executor.result = ExecutionResult(output: "Hello", error: "", exitCode: 0, timedOut: false, wasCancelled: false)
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        let result = await interactor.executeCode(code: "print(\"Hello\")", language: .swift, input: "")

        XCTAssertEqual(executor.lastRequest?.code, "print(\"Hello\")")
        XCTAssertEqual(executor.lastRequest?.language, .swift)
        XCTAssertEqual(result.output, "Hello")
    }

    @MainActor
    func testCancelExecutionDelegatesToService() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )

        // Should not throw
        interactor.cancelExecution()
    }
}
