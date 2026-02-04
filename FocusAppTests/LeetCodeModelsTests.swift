@testable import FocusApp
import XCTest

final class LeetCodeModelsTests: XCTestCase {
    func testErrorDescriptions() {
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.httpStatus(404).errorDescription, "Unexpected HTTP status: 404")
        XCTAssertEqual(LeetCodeError.invalidURL.errorDescription, "Invalid LeetCode API URL")
        XCTAssertEqual(LeetCodeError.noData.errorDescription, "No data received from LeetCode")
        XCTAssertEqual(LeetCodeError.decodingError.errorDescription, "Failed to decode LeetCode response")
        XCTAssertEqual(LeetCodeError.invalidPayload.errorDescription, "Unexpected data from LeetCode")
    }

    func testSubmissionListDecodesSubmissionKey() throws {
        let json = """
        {"submission": [{"titleSlug": "two-sum"}]}
        """
        let response: LeetCodeRestSubmissionListResponse = try decode(json)
        XCTAssertEqual(response.submissions.map { $0.titleSlug }, ["two-sum"])
    }

    func testSubmissionListDecodesSubmissionsKey() throws {
        let json = """
        {"submissions": [{"titleSlug": "reverse-linked-list"}]}
        """
        let response: LeetCodeRestSubmissionListResponse = try decode(json)
        XCTAssertEqual(response.submissions.map { $0.titleSlug }, ["reverse-linked-list"])
    }

    func testSubmissionListDefaultsToEmptyWhenMissingKeys() throws {
        let json = "{}"
        let response: LeetCodeRestSubmissionListResponse = try decode(json)
        XCTAssertTrue(response.submissions.isEmpty)
    }

    func testProblemResponseUsesFallbackFields() throws {
        let json = """
        {
          "questionTitle": "Two Sum",
          "question": "<p>Desc</p>",
          "exampleTestcases": "1\n2",
          "sampleTestCase": "1",
          "difficulty": "Easy",
          "codeSnippets": [{"langSlug": "swift", "code": "// code"}]
        }
        """
        let response: LeetCodeRestProblemResponse = try decode(json)
        XCTAssertEqual(response.title, "Two Sum")
        XCTAssertEqual(response.content, "<p>Desc</p>")
        XCTAssertEqual(response.codeSnippets.first?.langSlug, "swift")
    }

    func testProblemResponseUsesPrimaryFields() throws {
        let json = """
        {
          "title": "Add Two Numbers",
          "content": "<p>Primary</p>",
          "exampleTestcases": "1\\n2",
          "sampleTestCase": "1",
          "difficulty": "Medium",
          "codeSnippets": [{"langSlug": "python3", "code": "# code"}]
        }
        """
        let response: LeetCodeRestProblemResponse = try decode(json)
        XCTAssertEqual(response.title, "Add Two Numbers")
        XCTAssertEqual(response.content, "<p>Primary</p>")
        XCTAssertEqual(response.codeSnippets.first?.langSlug, "python3")
    }

    func testUserProfileResponseDecodesProfile() throws {
        let json = """
        {"profile": {"username": "ashim"}}
        """
        let response: LeetCodeUserProfileResponse = try decode(json)
        XCTAssertEqual(response.username, "ashim")
    }

    func testUserProfileResponseDecodesTopLevelUsername() throws {
        let json = """
        {"username": "top-level"}
        """
        let response: LeetCodeUserProfileResponse = try decode(json)
        XCTAssertEqual(response.username, "top-level")
    }

    func testUserProfileResponseDecodesUserProfileKey() throws {
        let json = """
        {"userProfile": {"username": "nested"}}
        """
        let response: LeetCodeUserProfileResponse = try decode(json)
        XCTAssertEqual(response.username, "nested")
    }

    func testUserProfileResponseReturnsNilWhenMissing() throws {
        let json = "{}"
        let response: LeetCodeUserProfileResponse = try decode(json)
        XCTAssertNil(response.username)
    }

    private func decode<T: Decodable>(_ json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }
}
