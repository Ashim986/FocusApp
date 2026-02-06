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
}
