@testable import FocusApp
import XCTest

final class LeetCodeErrorsTests: XCTestCase {
    func testNetworkErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.httpStatus(500).errorDescription, "Unexpected HTTP status: 500")
    }

    func testLeetCodeErrorDescriptions() {
        XCTAssertEqual(LeetCodeError.invalidURL.errorDescription, "Invalid LeetCode API URL")
        XCTAssertEqual(LeetCodeError.noData.errorDescription, "No data received from LeetCode")
        XCTAssertEqual(LeetCodeError.decodingError.errorDescription, "Failed to decode LeetCode response")
        XCTAssertEqual(LeetCodeError.invalidPayload.errorDescription, "Unexpected data from LeetCode")
    }

    func testNetworkErrorHTTPStatusIncludesCode() {
        let error = NetworkError.httpStatus(403)
        XCTAssertTrue(error.errorDescription?.contains("403") == true)
    }

    func testLeetCodeErrorCasesAreDifferent() {
        let allCases: [LeetCodeError] = [.invalidURL, .noData, .decodingError, .invalidPayload]

        for error in allCases {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }

        XCTAssertEqual(allCases.count, 4)
    }
}
