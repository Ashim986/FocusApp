@testable import FocusApp
import XCTest

final class LeetCodeConstantsTests: XCTestCase {
    func testRecentSubmissionsLimit() {
        XCTAssertEqual(LeetCodeConstants.recentSubmissionsLimit, 1000)
        XCTAssertGreaterThan(LeetCodeConstants.recentSubmissionsLimit, 0)
    }

    func testManualSubmissionsLimit() {
        XCTAssertEqual(LeetCodeConstants.manualSubmissionsLimit, 5000)
        XCTAssertGreaterThan(LeetCodeConstants.manualSubmissionsLimit, LeetCodeConstants.recentSubmissionsLimit)
    }

    func testRestBaseURLIsValid() {
        let url = LeetCodeConstants.restBaseURL
        XCTAssertNotNil(url.scheme)
        XCTAssertEqual(url.scheme, "https")
        XCTAssertNotNil(url.host)
    }

    func testSyncIntervalIsPositive() {
        XCTAssertGreaterThan(LeetCodeConstants.syncInterval, 0)
        XCTAssertEqual(LeetCodeConstants.syncInterval, 3600)
    }

    func testGraphQLBaseURLIsValid() {
        let url = LeetCodeConstants.graphQLBaseURL
        XCTAssertNotNil(url.scheme)
        XCTAssertEqual(url.scheme, "https")
        XCTAssertNotNil(url.host)
    }
}
