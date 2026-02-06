@testable import FocusApp
import XCTest

final class PlanCalendarTests: XCTestCase {
    func testBaseDayNumberClampsToPlanRange() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let calendar = PlanCalendar(calendar: .init(identifier: .gregorian), startDate: start)

        let before = makeDate(year: 2026, month: 2, day: 1)
        XCTAssertEqual(calendar.baseDayNumber(today: before), 1)

        let after = makeDate(year: 2026, month: 3, day: 1)
        XCTAssertEqual(calendar.baseDayNumber(today: after), dsaPlan.count)
    }

    func testCurrentDayNumberAppliesOffset() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let calendar = PlanCalendar(calendar: .init(identifier: .gregorian), startDate: start)

        XCTAssertEqual(calendar.currentDayNumber(today: start, offset: 0), 1)
        XCTAssertEqual(calendar.currentDayNumber(today: start, offset: 2), 3)
    }

    func testDSAPlanHasPrioritySprintAndCoreDays() {
        XCTAssertEqual(dsaPlan.count, 15)
        XCTAssertEqual(dsaPlan.first?.problems.count, 11)
        XCTAssertEqual(dsaPlan.dropFirst().first?.problems.count, 14)
        let remainingCounts = dsaPlan.dropFirst(2).map { $0.problems.count }
        XCTAssertEqual(remainingCounts.filter { $0 == 3 }.count, 3)
        XCTAssertTrue(remainingCounts.allSatisfy { $0 == 5 || $0 == 3 })
        XCTAssertEqual(dsaPlan.reduce(0) { $0 + $1.problems.count }, 84)
    }

    func testDSAPlanIncludesPreCompletedTopics() {
        XCTAssertEqual(preCompletedTopics.count, 3)
        XCTAssertTrue(preCompletedTopics.contains("Arrays & Hashing"))
        XCTAssertEqual(dsaPlan.first?.topic, "Priority Sprint I")
        XCTAssertEqual(dsaPlan.first?.problems.first?.name, "Two Sum")
    }

    func testProblemCodableRoundTrip() throws {
        let original = Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com/problems/two-sum/")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Problem.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.difficulty, original.difficulty)
        XCTAssertEqual(decoded.url, original.url)
    }
}
