@testable import FocusApp
import XCTest

final class LeetCodeConstantsTests: XCTestCase {
    func testRecentSubmissionsLimit() {
        XCTAssertEqual(LeetCodeConstants.recentSubmissionsLimit, 200)
        XCTAssertGreaterThan(LeetCodeConstants.recentSubmissionsLimit, 0)
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
}
