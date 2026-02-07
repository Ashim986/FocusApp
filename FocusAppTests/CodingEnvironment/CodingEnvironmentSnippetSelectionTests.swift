@testable import FocusApp
import XCTest

@MainActor
final class CodingEnvironmentSnippetSelectionTests: XCTestCase {
    @MainActor
    func testInitialCodeUsesStoredCodeWhenNonDefault() {
        let presenter = makeCodingPresenter()
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem
        let key = presenter.solutionKey(for: problem, language: .swift)
        presenter.interactor.saveSolution(code: "print(\"custom\")", for: key)

        let code = presenter.initialCode(for: problem, language: .swift)

        XCTAssertEqual(code, "print(\"custom\")")
    }

    @MainActor
    func testInitialCodeUsesSnippetFromCacheWhenStoredIsDefault() {
        let presenter = makeCodingPresenter()
        let problem = problemWithSlug("reverse-linked-list")
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
            metaData: nil,
            questionId: nil
        )
        presenter.problemContentCache["reverse-linked-list"] = CodingEnvironmentPresenter.CachedContent(
            content: cached, timestamp: Date()
        )

        let code = presenter.initialCode(for: problem, language: .swift)

        XCTAssertEqual(code, "class Solution { }")
    }

    @MainActor
    func testInitialCodeUsesTemplateWhenNoSnippet() {
        let presenter = makeCodingPresenter()
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
            metaData: meta,
            questionId: nil
        )
        presenter.problemContentCache["two-sum"] = CodingEnvironmentPresenter.CachedContent(
            content: cached, timestamp: Date()
        )

        let problem = Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com/problems/two-sum/")
        let code = presenter.initialCode(for: problem, language: .swift)

        XCTAssertTrue(code.contains("class Solution"))
        XCTAssertTrue(code.contains("func twoSum"))
    }

    @MainActor
    func testApplySnippetIfNeededPrefersSnippet() {
        let presenter = makeCodingPresenter()
        let problem = problemWithSlug("reverse-linked-list")
        presenter.selectedProblem = problem
        presenter.setCode("")

        let content = QuestionContent(
            title: "Reverse Linked List",
            content: "",
            exampleTestcases: "",
            sampleTestCase: "",
            difficulty: "Easy",
            codeSnippets: ["swift": "class Solution { }"],
            metaData: nil,
            questionId: nil
        )

        presenter.applySnippetIfNeeded(from: content)

        XCTAssertEqual(presenter.code, "class Solution { }")
    }

    @MainActor
    func testApplySnippetIfNeededFallsBackToTemplate() {
        let presenter = makeCodingPresenter()
        let problem = problemWithSlug("reverse-linked-list")
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
            metaData: meta,
            questionId: nil
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
            metaData: nil,
            questionId: nil
        )

        let presenter = CodingEnvironmentPresenter(interactor: makeCodingInteractor())
        let snippet = presenter.snippetForLanguage(.python, from: content)

        XCTAssertEqual(snippet, "print('py3')")
    }
}
