@testable import FocusApp
import XCTest

final class CodingEnvironmentIntegrationTests: XCTestCase {
    @MainActor
    func testOpenProblemLoadsSnippetAndTestCases() async {
        let harness = makeCodingEnvironmentHarness()
        let flow = CodingEnvironmentFlow(app: CodingEnvironmentApp(presenter: harness.presenter))
        let slug = "merge-two-sorted-lists"

        harness.client.contentBySlug[slug] = makeQuestionContent(
            title: "Merge Two Sorted Lists",
            functionName: "mergeTwoLists",
            exampleTestcases: "[1]\n[2]",
            output: "[1,2]"
        )

        let editor = flow.openProblem(slug: slug, source: .today)
        let content = await editor.waitForContent(slug: slug)

        XCTAssertNotNil(content)
        editor.assertSelectedProblem(slug: slug)
        editor.assertCodeContains("func mergeTwoLists")
        XCTAssertFalse(harness.presenter.testCases.isEmpty)
    }

    @MainActor
    func testSwitchingProblemsIgnoresStaleContent() async {
        let harness = makeCodingEnvironmentHarness()
        let flow = CodingEnvironmentFlow(app: CodingEnvironmentApp(presenter: harness.presenter))
        let slowSlug = "merge-two-sorted-lists"
        let fastSlug = "group-anagrams"

        harness.client.contentBySlug[slowSlug] = makeQuestionContent(
            title: "Merge Two Sorted Lists",
            functionName: "mergeTwoLists"
        )
        harness.client.contentBySlug[fastSlug] = makeQuestionContent(
            title: "Group Anagrams",
            functionName: "groupAnagrams"
        )
        harness.client.delayBySlug[slowSlug] = 150_000_000

        let editor = flow.openProblem(slug: slowSlug, source: .selection)
        _ = editor.selectProblem(slug: fastSlug)

        _ = await editor.waitForContent(slug: fastSlug)
        editor.assertSelectedProblem(slug: fastSlug)
        editor.assertCodeContains("func groupAnagrams")

        try? await Task.sleep(nanoseconds: 200_000_000)
        editor.assertSelectedProblem(slug: fastSlug)
        editor.assertCodeContains("func groupAnagrams")
    }

    @MainActor
    func testRunCodeUpdatesOutput() async {
        let harness = makeCodingEnvironmentHarness()
        let flow = CodingEnvironmentFlow(app: CodingEnvironmentApp(presenter: harness.presenter))
        let slug = "two-sum"

        harness.client.contentBySlug[slug] = makeQuestionContent(
            title: "Two Sum",
            functionName: "twoSum"
        )
        harness.executor.result = ExecutionResult(
            output: "OK",
            error: "",
            exitCode: 0,
            timedOut: false,
            wasCancelled: false
        )

        let editor = flow.openProblem(slug: slug, source: .selection)
        _ = await editor.waitForContent(slug: slug)
        harness.presenter.testCases = []

        _ = editor.runCode()
        let finished = await editor.waitForRunCompletion(timeout: 1.5)

        XCTAssertTrue(finished)
        editor.assertOutputContains("OK")
    }
}
