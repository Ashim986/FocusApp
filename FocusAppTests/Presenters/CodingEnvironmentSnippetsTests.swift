@testable import FocusApp
import XCTest

final class CodingEnvironmentSnippetsTests: XCTestCase {
    @MainActor
    func testInitialCodeUsesStoredCodeWhenNonDefault() {
        let presenter = makePresenter()
        let problem = dsaPlan[0].problems[0]
        presenter.selectedProblem = problem
        let key = presenter.solutionKey(for: problem, language: .swift)
        presenter.interactor.saveSolution(code: "print(\"custom\")", for: key)

        let code = presenter.initialCode(for: problem, language: .swift)

        XCTAssertEqual(code, "print(\"custom\")")
    }

    @MainActor
    func testInitialCodeUsesSnippetFromCacheWhenStoredIsDefault() {
        let presenter = makePresenter()
        let problem = dsaPlan[0].problems[0]
        presenter.selectedProblem = problem
        let key = presenter.solutionKey(for: problem, language: .swift)
        presenter.interactor.saveSolution(code: ProgrammingLanguage.swift.defaultTemplate, for: key)

        let cached = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution { }"],
            metaData: nil
        )
        presenter.problemContentCache["reverse-linked-list"] = cached

        let code = presenter.initialCode(for: problem, language: .swift)

        XCTAssertEqual(code, "class Solution { }")
    }

    @MainActor
    func testInitialCodeUsesTemplateWhenNoSnippet() {
        let presenter = makePresenter()
        let problem = dsaPlan[0].problems[0]
        presenter.selectedProblem = problem
        let meta = functionMetaJSON(
            name: "twoSum",
            params: [("nums", "integer[]"), ("target", "integer")],
            returnType: "integer[]"
        )
        let cached = QuestionContent(
            title: "Two Sum",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: meta
        )
        presenter.problemContentCache["two-sum"] = cached

        let code = presenter.initialCode(for: Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com/problems/two-sum/"), language: .swift)

        XCTAssertTrue(code.contains("class Solution"))
        XCTAssertTrue(code.contains("func twoSum"))
    }

    @MainActor
    func testApplySnippetIfNeededPrefersSnippet() {
        let presenter = makePresenter()
        let problem = dsaPlan[0].problems[0]
        presenter.selectedProblem = problem
        presenter.setCode("")

        let content = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution { }"],
            metaData: nil
        )

        presenter.applySnippetIfNeeded(from: content)

        XCTAssertEqual(presenter.code, "class Solution { }")
    }

    @MainActor
    func testApplySnippetIfNeededFallsBackToTemplate() {
        let presenter = makePresenter()
        let problem = dsaPlan[0].problems[0]
        presenter.selectedProblem = problem
        presenter.setCode("")
        let meta = functionMetaJSON(
            name: "maxDepth",
            params: [("root", "TreeNode")],
            returnType: "integer"
        )
        let content = QuestionContent(
            title: "Max Depth",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: [:],
            metaData: meta
        )

        presenter.applySnippetIfNeeded(from: content)

        XCTAssertTrue(presenter.code.contains("class Solution"))
        XCTAssertTrue(presenter.code.contains("TreeNode"))
    }

    func testSnippetForLanguageUsesSlugOrder() {
        let content = QuestionContent(
            title: "",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["python": "print('py')", "python3": "print('py3')"],
            metaData: nil
        )

        let snippet = CodingEnvironmentPresenter(interactor: makeInteractor()).snippetForLanguage(.python, from: content)

        XCTAssertEqual(snippet, "print('py3')")
    }

    func testTemplateBuilderSwiftFunctionTemplateIncludesSupportTypes() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "merge",
            params: [("list", "ListNode"), ("tree", "TreeNode")],
            returnType: "ListNode"
        ))
        let template = LeetCodeTemplateBuilder.template(for: meta!, language: .swift)

        XCTAssertNotNil(template)
        XCTAssertTrue(template?.contains("class ListNode") == true)
        XCTAssertTrue(template?.contains("class TreeNode") == true)
        XCTAssertTrue(template?.contains("func merge") == true)
    }

    func testTemplateBuilderPythonFunctionTemplateIncludesImports() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("nums", "integer[]"), ("node", "ListNode")],
            returnType: "Foo"
        ))
        let template = LeetCodeTemplateBuilder.template(for: meta!, language: .python)

        XCTAssertNotNil(template)
        XCTAssertTrue(template?.contains("from typing import") == true)
        XCTAssertTrue(template?.contains("List") == true)
        XCTAssertTrue(template?.contains("Optional") == true)
        XCTAssertTrue(template?.contains("Any") == true)
    }

    func testTemplateBuilderClassDesignTemplates() {
        let metaJSON = """
        {"classname":"LRUCache","methods":[{"name":"LRUCache","params":[{"name":"capacity","type":"integer"}],"return":{"type":"void"}},{"name":"get","params":[{"name":"key","type":"integer"}],"return":{"type":"integer"}}]}
        """
        let meta = LeetCodeMetaData.decode(from: metaJSON)
        let swiftTemplate = LeetCodeTemplateBuilder.template(for: meta!, language: .swift)
        let pythonTemplate = LeetCodeTemplateBuilder.template(for: meta!, language: .python)

        XCTAssertTrue(swiftTemplate?.contains("class LRUCache") == true)
        XCTAssertTrue(swiftTemplate?.contains("init") == true)
        XCTAssertTrue(pythonTemplate?.contains("class LRUCache") == true)
        XCTAssertTrue(pythonTemplate?.contains("def __init__") == true)
    }

    func testSafeIdentifiersEscapeKeywords() {
        XCTAssertEqual(LeetCodeTemplateBuilder.swiftSafeIdentifier("class", index: 0), "`class`")
        XCTAssertEqual(LeetCodeTemplateBuilder.pythonSafeIdentifier("class", index: 0), "class_")
    }

    func testExecutionWrapperWrapSwiftAddsRunnerAndSupport() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "twoSum",
            params: [("head", "ListNode")],
            returnType: "integer"
        ))
        let code = "class Solution { func twoSum(_ head: ListNode?) -> Int { return 0 } }"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta!)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
        XCTAssertTrue(wrapped.contains("final class ListNode"))
        XCTAssertTrue(wrapped.contains("#sourceLocation"))
    }

    func testExecutionWrapperSkipsWhenClassDesign() {
        let metaJSON = """
        {"classname":"MyQueue","methods":[{"name":"MyQueue","params":[],"return":{"type":"void"}}]}
        """
        let meta = LeetCodeMetaData.decode(from: metaJSON)
        let code = "class MyQueue {}"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta!)

        XCTAssertEqual(wrapped, code)
    }

    func testExecutionWrapperWrapPythonAddsRunner() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "solve",
            params: [("values", "integer[]")],
            returnType: "integer"
        ))
        let code = "class Solution:\n    def solve(self, values):\n        return 0"
        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .python, meta: meta!)

        XCTAssertTrue(wrapped.contains("FocusApp LeetCode Runner"))
        XCTAssertTrue(wrapped.contains("def _run"))
    }

    func testExecutionWrapperAddsListNodeWhenOnlyInComment() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        ))
        let code = """
        // class ListNode {}
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta!)

        XCTAssertTrue(wrapped.contains("final class ListNode"))
    }

    func testExecutionWrapperSkipsListNodeSupportWhenDefined() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        ))
        let code = """
        class ListNode { var val = 0; var next: ListNode? }
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta!)

        XCTAssertFalse(wrapped.contains("final class ListNode"))
    }

    func testExecutionWrapperAddsSupportWhenListNodeInString() {
        let meta = LeetCodeMetaData.decode(from: functionMetaJSON(
            name: "reverseList",
            params: [("head", "ListNode")],
            returnType: "ListNode"
        ))
        let code = """
        let sample = "class ListNode {}"
        class Solution {
            func reverseList(_ head: ListNode?) -> ListNode? { return head }
        }
        """

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta!)

        XCTAssertTrue(wrapped.contains("final class ListNode"))
    }

    // MARK: - Helpers

    @MainActor
    private func makePresenter() -> CodingEnvironmentPresenter {
        CodingEnvironmentPresenter(interactor: makeInteractor())
    }

    @MainActor
    private func makeInteractor() -> CodingEnvironmentInteractor {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        return CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: FakeLeetCodeClient(),
            executionService: FakeCodeExecutor(),
            solutionStore: FakeSolutionStore()
        )
    }

    private func functionMetaJSON(name: String, params: [(String, String)], returnType: String) -> String {
        let paramsJSON = params.map { "{\"name\":\"\($0.0)\",\"type\":\"\($0.1)\"}" }.joined(separator: ",")
        return "{\"name\":\"\(name)\",\"params\":[\(paramsJSON)],\"return\":{\"type\":\"\(returnType)\"}}"
    }
}
