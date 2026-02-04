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
}
