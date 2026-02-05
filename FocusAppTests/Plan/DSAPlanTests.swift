@testable import FocusApp
import XCTest

final class DSAPlanTests: XCTestCase {
    func testPlanHas13Days() {
        XCTAssertEqual(dsaPlan.count, 13)
    }

    func testEachDayHas5Problems() {
        for day in dsaPlan {
            XCTAssertEqual(day.problems.count, 5, "Day \(day.id) should have 5 problems")
        }
    }

    func testTotalProblemCountIs65() {
        let total = dsaPlan.reduce(0) { $0 + $1.problems.count }
        XCTAssertEqual(total, 65)
    }

    func testAllProblemsHaveValidLeetCodeURLs() {
        for day in dsaPlan {
            for problem in day.problems {
                XCTAssertTrue(
                    problem.url.hasPrefix("https://leetcode.com/problems/"),
                    "\(problem.name) has invalid URL: \(problem.url)"
                )
                XCTAssertNotNil(URL(string: problem.url), "\(problem.name) URL is malformed")
            }
        }
    }

    func testDifficultyEnumRawValues() {
        XCTAssertEqual(Difficulty.easy.rawValue, "Easy")
        XCTAssertEqual(Difficulty.medium.rawValue, "Medium")
        XCTAssertEqual(Difficulty.allCases.count, 2)
    }

    func testProblemCodableRoundTrip() throws {
        let original = Problem(name: "Test Problem", difficulty: .medium, url: "https://leetcode.com/problems/test/")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Problem.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.difficulty, original.difficulty)
        XCTAssertEqual(decoded.url, original.url)
    }

    func testPreCompletedTopicsCount() {
        XCTAssertEqual(preCompletedTopics.count, 3)
        XCTAssertTrue(preCompletedTopics.contains("Arrays & Hashing"))
        XCTAssertTrue(preCompletedTopics.contains("Two Pointers"))
        XCTAssertTrue(preCompletedTopics.contains("Sliding Window"))
    }

    func testDayIdsAreSequential() {
        let ids = dsaPlan.map { $0.id }
        XCTAssertEqual(ids, Array(1...13))
    }
}
