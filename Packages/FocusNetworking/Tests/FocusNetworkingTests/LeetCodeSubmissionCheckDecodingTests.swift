import FocusNetworking
import XCTest

final class LeetCodeSubmissionCheckDecodingTests: XCTestCase {
    func testDecodesCompletedPayloadWithMixedTypes() throws {
        let payload = """
        {
          "status_code": 10,
          "lang": "swift",
          "run_success": true,
          "status_runtime": "0 ms",
          "memory": 19900000,
          "finished": true,
          "total_correct": 28,
          "total_testcases": 28,
          "runtime_percentile": 100,
          "status_memory": "19.9 MB",
          "memory_percentile": "73.2",
          "status_msg": "Accepted"
        }
        """

        let result = try JSONDecoder().decode(
            LeetCodeSubmissionCheck.self,
            from: Data(payload.utf8)
        )

        XCTAssertEqual(result.statusCode, 10)
        XCTAssertEqual(result.statusMsg, "Accepted")
        XCTAssertEqual(result.runSuccess, true)
        XCTAssertEqual(result.finished, true)
        XCTAssertEqual(result.totalCorrect, 28)
        XCTAssertEqual(result.totalTestcases, 28)
        XCTAssertEqual(result.memory, "19900000")
        XCTAssertEqual(result.statusMemory, "19.9 MB")
        XCTAssertEqual(result.runtimePercentile, 100)
        XCTAssertNotNil(result.memoryPercentile)
        XCTAssertEqual(result.memoryPercentile ?? 0, 73.2, accuracy: 0.0001)
        XCTAssertTrue(result.isComplete)
    }

    func testDecodesBooleanAndNumericValuesFromString() throws {
        let payload = """
        {
          "finished": "true",
          "run_success": "1",
          "total_correct": "5",
          "total_testcases": "5",
          "status_code": "10",
          "status_msg": "Accepted"
        }
        """

        let result = try JSONDecoder().decode(
            LeetCodeSubmissionCheck.self,
            from: Data(payload.utf8)
        )

        XCTAssertEqual(result.finished, true)
        XCTAssertEqual(result.runSuccess, true)
        XCTAssertEqual(result.totalCorrect, 5)
        XCTAssertEqual(result.totalTestcases, 5)
        XCTAssertEqual(result.statusCode, 10)
        XCTAssertTrue(result.isComplete)
    }
}
