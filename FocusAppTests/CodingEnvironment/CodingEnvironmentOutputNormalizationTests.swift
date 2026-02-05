@testable import FocusApp
import XCTest

final class CodingEnvironmentOutputNormalizationTests: XCTestCase {
    @MainActor
    func testNormalizeOutputReturnsTrimmedWhenExpectedEmpty() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("  output  \n", expected: "")

        XCTAssertEqual(normalized, "output")
    }

    @MainActor
    func testNormalizeOutputUsesExpectedSuffix() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("debug\n42", expected: "42")

        XCTAssertEqual(normalized, "42")
    }

    @MainActor
    func testNormalizeOutputUsesLastLineForSingleLineExpected() {
        let presenter = makeCodingPresenter()
        let normalized = presenter.normalizeOutputForComparison("log\nvalue", expected: "value")

        XCTAssertEqual(normalized, "value")
    }
}
