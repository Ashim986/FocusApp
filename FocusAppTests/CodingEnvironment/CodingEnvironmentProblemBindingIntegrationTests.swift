@testable import FocusApp
import XCTest

final class CodingEnvironmentProblemBindingIntegrationTests: XCTestCase {
    @MainActor
    func testOpenFromTodayKeepsContentInSync() async {
        let client = DelayedLeetCodeClient()
        let presenter = makePresenter(client: client)
        let app = CodingEnvironmentApp(presenter: presenter)
        let todayProblem = "merge-two-sorted-lists"

        client.contentBySlug[todayProblem] = makeQuestionContent(
            title: "Merge Two Sorted Lists",
            functionName: "mergeTwoLists"
        )

        let editor = app.problemSelection().openFromToday(slug: todayProblem)
        _ = await editor.waitForContent(slug: todayProblem)

        editor.assertSelectedProblem(slug: todayProblem)
        editor.assertCodeContains("func mergeTwoLists")
    }

    @MainActor
    func testOpenFromPlanKeepsContentInSync() async {
        let client = DelayedLeetCodeClient()
        let presenter = makePresenter(client: client)
        let app = CodingEnvironmentApp(presenter: presenter)
        let planProblem = "number-of-islands"

        client.contentBySlug[planProblem] = makeQuestionContent(
            title: "Number of Islands",
            functionName: "numIslands"
        )

        let editor = app.problemSelection().openFromPlan(slug: planProblem)
        _ = await editor.waitForContent(slug: planProblem)

        editor.assertSelectedProblem(slug: planProblem)
        editor.assertCodeContains("func numIslands")
    }

    @MainActor
    func testSwitchingProblemsIgnoresStaleContent() async {
        let client = DelayedLeetCodeClient()
        let presenter = makePresenter(client: client)
        let app = CodingEnvironmentApp(presenter: presenter)
        let slowSlug = "merge-two-sorted-lists"
        let fastSlug = "group-anagrams"

        client.contentBySlug[slowSlug] = makeQuestionContent(
            title: "Merge Two Sorted Lists",
            functionName: "mergeTwoLists"
        )
        client.contentBySlug[fastSlug] = makeQuestionContent(
            title: "Group Anagrams",
            functionName: "groupAnagrams"
        )
        client.delayBySlug[slowSlug] = 150_000_000

        let editor = app.problemSelection().openFromSelection(slug: slowSlug)
        _ = editor.selectProblem(slug: fastSlug)

        _ = await editor.waitForContent(slug: fastSlug)
        editor.assertSelectedProblem(slug: fastSlug)
        editor.assertCodeContains("func groupAnagrams")

        try? await Task.sleep(nanoseconds: 200_000_000)
        editor.assertSelectedProblem(slug: fastSlug)
        editor.assertCodeContains("func groupAnagrams")
    }

    @MainActor
    func testBackToSelectionThenSelectNewProblemResetsContent() async {
        let client = DelayedLeetCodeClient()
        let presenter = makePresenter(client: client)
        let app = CodingEnvironmentApp(presenter: presenter)
        let firstSlug = "merge-two-sorted-lists"
        let secondSlug = "group-anagrams"

        client.contentBySlug[firstSlug] = makeQuestionContent(
            title: "Merge Two Sorted Lists",
            functionName: "mergeTwoLists"
        )
        client.contentBySlug[secondSlug] = makeQuestionContent(
            title: "Group Anagrams",
            functionName: "groupAnagrams"
        )

        let editor = app.problemSelection().openFromSelection(slug: firstSlug)
        _ = await editor.waitForContent(slug: firstSlug)
        editor.backToSelection()

        _ = editor.selectProblem(slug: secondSlug)
        _ = await editor.waitForContent(slug: secondSlug)

        editor.assertSelectedProblem(slug: secondSlug)
        editor.assertCodeContains("func groupAnagrams")
    }
}

private final class DelayedLeetCodeClient: LeetCodeClientProtocol {
    var contentBySlug: [String: QuestionContent] = [:]
    var delayBySlug: [String: UInt64] = [:]

    func validateUsername(_ username: String) async throws -> Bool { true }

    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }

    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        if let delay = delayBySlug[slug] {
            try? await Task.sleep(nanoseconds: delay)
        }
        return contentBySlug[slug]
    }
}

@MainActor
private func makePresenter(client: LeetCodeClientProtocol) -> CodingEnvironmentPresenter {
    let start = makeDate(year: 2026, month: 2, day: 3)
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: start),
        dateProvider: FixedDateProvider(date: start)
    )
    let interactor = CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: client,
        executionService: FakeCodeExecutor(),
        solutionStore: FakeSolutionStore()
    )
    return CodingEnvironmentPresenter(interactor: interactor)
}

private func makeQuestionContent(title: String, functionName: String) -> QuestionContent {
    QuestionContent(
        title: title,
        content: "<strong>Output:</strong> []",
        exampleTestcases: "[]",
        sampleTestCase: "",
        difficulty: "Medium",
        codeSnippets: [
            "swift": "class Solution {\n    func \(functionName)(_ input: [Int]) -> [Int] {\n        return []\n    }\n}"
        ],
        metaData: functionMetaJSON(
            name: functionName,
            params: [("input", "integer[]")],
            returnType: "integer[]"
        )
    )
}
