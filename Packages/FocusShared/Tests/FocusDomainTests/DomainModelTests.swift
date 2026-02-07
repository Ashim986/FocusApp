import FocusDomain
import XCTest

final class DomainModelTests: XCTestCase {
    func testProblemDisplayNameIncludesLeetCodeNumber() {
        let problem = Problem(
            name: "Two Sum",
            difficulty: .easy,
            url: "https://leetcode.com/problems/two-sum/",
            leetcodeNumber: 1
        )

        XCTAssertEqual(problem.displayName, "#1 Two Sum")
    }

    func testProblemDisplayNameFallsBackToNameWhenNumberIsMissing() {
        let problem = Problem(
            name: "Two Sum",
            difficulty: .easy,
            url: "https://leetcode.com/problems/two-sum/"
        )

        XCTAssertEqual(problem.displayName, "Two Sum")
    }

    func testProblemKeyStorageKey() {
        let key = ProblemKey(dayID: 3, problemIndex: 4)
        XCTAssertEqual(key.storageKey, "3-4")
    }

    func testStudyPlanCodableRoundTrip() throws {
        let plan = StudyPlan(
            preCompletedTopics: ["Arrays & Hashing"],
            days: [
                StudyDay(
                    id: 1,
                    date: "Feb 6",
                    topic: "Priority Sprint I",
                    problems: [
                        Problem(
                            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                            name: "Two Sum",
                            difficulty: .easy,
                            url: "https://leetcode.com/problems/two-sum/",
                            leetcodeNumber: 1
                        )
                    ]
                )
            ]
        )

        let data = try JSONEncoder().encode(plan)
        let decoded = try JSONDecoder().decode(StudyPlan.self, from: data)
        XCTAssertEqual(decoded, plan)
    }
}
