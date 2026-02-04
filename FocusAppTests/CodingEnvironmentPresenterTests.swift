@testable import FocusApp
import XCTest

final class CodingEnvironmentPresenterTests: XCTestCase {
    @MainActor
    func testSelectProblemLoadsSnippetWhenNoUserCode() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let snippet = "class Solution { }"
        client.contentBySlug["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": snippet, "python3": "def solve():\n    pass"],
            metaData: nil
        )
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(appStore: store, leetCodeClient: client, executionService: executor)
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let problem = dsaPlan[0].problems[0]
        presenter.selectProblem(problem, at: 0, day: 1)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.code, snippet)
    }

    @MainActor
    func testSelectProblemKeepsSavedCode() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.contentBySlug["reverse-linked-list"] = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution { }"],
            metaData: nil
        )
        let executor = FakeCodeExecutor()
        let interactor = CodingEnvironmentInteractor(appStore: store, leetCodeClient: client, executionService: executor)
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let problem = dsaPlan[0].problems[0]
        let key = presenter.solutionKey(for: problem, language: .swift)
        store.saveSolution(code: "print(\"hi\")", for: key)

        presenter.selectProblem(problem, at: 0, day: 1)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.code, "print(\"hi\")")
    }
}
