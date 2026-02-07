@testable import FocusApp
import XCTest

final class CodingEnvironmentOutputNormalizationTests: XCTestCase {
    @MainActor
    func testNormalizeOutputReturnsTrimmedWhenExpectedEmpty() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("  output  \n", expected: "")

        XCTAssertEqual(normalized.displayValue, "output")
        XCTAssertEqual(normalized.comparisonValue, "output")
    }

    @MainActor
    func testNormalizeOutputUsesExpectedSuffix() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("debug\n42", expected: "42")

        // Display should show full raw output, comparison should extract the expected suffix
        XCTAssertEqual(normalized.displayValue, "debug\n42")
        XCTAssertEqual(normalized.comparisonValue, "42")
    }

    @MainActor
    func testNormalizeOutputUsesLastLineForSingleLineExpected() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("log\nvalue", expected: "value")

        // Display should show full raw output, comparison should use last line
        XCTAssertEqual(normalized.displayValue, "log\nvalue")
        XCTAssertEqual(normalized.comparisonValue, "value")
    }

    // MARK: - outputMatches tests

    @MainActor
    func testOutputMatchesExactMatch() {
        let presenter = makeCodingPresenter()
        XCTAssertTrue(presenter.outputMatches("[1,2]", expected: "[1,2]"))
    }

    @MainActor
    func testOutputMatchesOrderMattersRejectsDifferentOrder() {
        let presenter = makeCodingPresenter()
        // Default orderMatters=true should reject different order
        XCTAssertFalse(presenter.outputMatches("[2,1]", expected: "[1,2]"))
        XCTAssertFalse(
            presenter.outputMatches("[2,1]", expected: "[1,2]", orderMatters: true)
        )
    }

    @MainActor
    func testOutputMatchesOrderInsensitiveAcceptsDifferentOrder() {
        let presenter = makeCodingPresenter()
        // orderMatters=false should accept different order for flat arrays
        XCTAssertTrue(
            presenter.outputMatches("[2,1]", expected: "[1,2]", orderMatters: false)
        )
    }

    @MainActor
    func testOutputMatchesOrderInsensitiveWithStrings() {
        let presenter = makeCodingPresenter()
        XCTAssertTrue(
            presenter.outputMatches(
                "[\"b\",\"a\"]",
                expected: "[\"a\",\"b\"]",
                orderMatters: false
            )
        )
    }

    @MainActor
    func testOutputMatchesOrderInsensitiveRejectsDifferentElements() {
        let presenter = makeCodingPresenter()
        // Different elements should still fail even with orderMatters=false
        XCTAssertFalse(
            presenter.outputMatches("[1,3]", expected: "[1,2]", orderMatters: false)
        )
    }

    @MainActor
    func testOutputMatchesNonArrayFallsBackToExact() {
        let presenter = makeCodingPresenter()
        // Non-array values: orderMatters=false has no effect, uses exact match
        XCTAssertFalse(
            presenter.outputMatches("true", expected: "false", orderMatters: false)
        )
        XCTAssertTrue(
            presenter.outputMatches("42", expected: "42", orderMatters: false)
        )
    }

    // MARK: - SolutionTestCase backward compatibility

    func testSolutionTestCaseOrderMattersDefaultsTrue() {
        let testCase = SolutionTestCase(input: "x", expectedOutput: "y")
        XCTAssertTrue(testCase.orderMatters)
    }

    func testSolutionTestCaseOrderMattersFalse() {
        let testCase = SolutionTestCase(
            input: "x",
            expectedOutput: "y",
            orderMatters: false
        )
        XCTAssertFalse(testCase.orderMatters)
    }

    func testSolutionTestCaseDecodesWithoutOrderMatters() throws {
        // Simulate legacy JSON without the orderMatters field
        let json = """
        {"id":"00000000-0000-0000-0000-000000000001","input":"a","expectedOutput":"b"}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(SolutionTestCase.self, from: data)
        XCTAssertEqual(decoded.input, "a")
        XCTAssertEqual(decoded.expectedOutput, "b")
        XCTAssertTrue(decoded.orderMatters, "Legacy JSON without orderMatters should default to true")
    }

    func testSolutionTestCaseDecodesWithOrderMattersFalse() throws {
        let json = """
        {"id":"00000000-0000-0000-0000-000000000001","input":"a","expectedOutput":"b","orderMatters":false}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoded = try JSONDecoder().decode(SolutionTestCase.self, from: data)
        XCTAssertFalse(decoded.orderMatters)
    }
}
