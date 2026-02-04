@testable import FocusApp
import XCTest

final class ProgrammingLanguageTests: XCTestCase {
    func testLanguageSlugs() {
        XCTAssertEqual(ProgrammingLanguage.swift.langSlug, "swift")
        XCTAssertEqual(ProgrammingLanguage.python.langSlug, "python3")
    }

    func testSnippetSlugs() {
        XCTAssertTrue(ProgrammingLanguage.swift.snippetSlugs.contains("swift"))
        XCTAssertTrue(ProgrammingLanguage.python.snippetSlugs.contains("python3"))
    }

    func testDefaultTemplatesNotEmpty() {
        XCTAssertFalse(ProgrammingLanguage.swift.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        XCTAssertFalse(ProgrammingLanguage.python.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    func testFileExtensions() {
        XCTAssertEqual(ProgrammingLanguage.swift.fileExtension, "swift")
        XCTAssertEqual(ProgrammingLanguage.python.fileExtension, "py")
    }

    func testExecutionResultFactories() {
        XCTAssertFalse(ExecutionResult.failure("nope").isSuccess)
        XCTAssertTrue(ExecutionResult.timeout().timedOut)
        XCTAssertTrue(ExecutionResult.cancelled().wasCancelled)
    }

    func testTestCaseInitialization() {
        let testCase = TestCase(input: "1 2 3", expectedOutput: "6")

        XCTAssertEqual(testCase.input, "1 2 3")
        XCTAssertEqual(testCase.expectedOutput, "6")
        XCTAssertNil(testCase.actualOutput)
        XCTAssertNil(testCase.passed)
        XCTAssertNotNil(testCase.id)
    }

    func testQuestionContentProperties() {
        let snippets = ["swift": "func solution()", "python3": "def solution():"]
        let content = QuestionContent(
            title: "Two Sum",
            content: "<p>Given an array...</p>",
            exampleTestcases: "[2,7,11,15]\n9",
            sampleTestCase: "[2,7,11,15]",
            difficulty: "Easy",
            codeSnippets: snippets
        )

        XCTAssertEqual(content.title, "Two Sum")
        XCTAssertEqual(content.difficulty, "Easy")
        XCTAssertEqual(content.codeSnippets.count, 2)
        XCTAssertEqual(content.codeSnippets["swift"], "func solution()")
    }

    func testExecutionResultIsSuccessConditions() {
        let success = ExecutionResult(output: "ok", error: "", exitCode: 0, timedOut: false, wasCancelled: false)
        XCTAssertTrue(success.isSuccess)

        let withError = ExecutionResult(output: "ok", error: "warning", exitCode: 0, timedOut: false, wasCancelled: false)
        XCTAssertFalse(withError.isSuccess)

        let badExitCode = ExecutionResult(output: "ok", error: "", exitCode: 1, timedOut: false, wasCancelled: false)
        XCTAssertFalse(badExitCode.isSuccess)

        let timedOut = ExecutionResult(output: "ok", error: "", exitCode: 0, timedOut: true, wasCancelled: false)
        XCTAssertFalse(timedOut.isSuccess)

        let cancelled = ExecutionResult(output: "ok", error: "", exitCode: 0, timedOut: false, wasCancelled: true)
        XCTAssertFalse(cancelled.isSuccess)
    }

    func testExecutionResultFailureFactoryValues() {
        let failure = ExecutionResult.failure("Something went wrong")

        XCTAssertEqual(failure.output, "")
        XCTAssertEqual(failure.error, "Something went wrong")
        XCTAssertEqual(failure.exitCode, -1)
        XCTAssertFalse(failure.timedOut)
        XCTAssertFalse(failure.wasCancelled)
    }

    func testExecutionResultTimeoutFactoryValues() {
        let timeout = ExecutionResult.timeout()

        XCTAssertEqual(timeout.output, "")
        XCTAssertEqual(timeout.error, "Execution timed out")
        XCTAssertEqual(timeout.exitCode, -1)
        XCTAssertTrue(timeout.timedOut)
        XCTAssertFalse(timeout.wasCancelled)
    }

    func testExecutionResultCancelledFactoryValues() {
        let cancelled = ExecutionResult.cancelled()

        XCTAssertEqual(cancelled.output, "")
        XCTAssertEqual(cancelled.error, "Execution stopped by user")
        XCTAssertEqual(cancelled.exitCode, -1)
        XCTAssertFalse(cancelled.timedOut)
        XCTAssertTrue(cancelled.wasCancelled)
    }
}
