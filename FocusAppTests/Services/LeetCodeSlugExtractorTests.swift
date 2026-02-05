@testable import FocusApp
import XCTest

final class LeetCodeSlugExtractorTests: XCTestCase {
    func testExtractSlugFromProblemURL() {
        let url = "https://leetcode.com/problems/reverse-linked-list/"
        XCTAssertEqual(LeetCodeSlugExtractor.extractSlug(from: url), "reverse-linked-list")
    }

    func testExtractSlugReturnsNilForInvalidURL() {
        let url = "https://example.com/problems/"
        XCTAssertNil(LeetCodeSlugExtractor.extractSlug(from: url))
    }
}
