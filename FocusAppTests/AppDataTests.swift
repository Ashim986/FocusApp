@testable import FocusApp
import XCTest

final class AppDataTests: XCTestCase {
    func testProblemCompletionAndCounts() {
        var data = AppData()
        data.progress["1-0"] = true
        data.progress["1-1"] = true

        XCTAssertTrue(data.isProblemCompleted(day: 1, problemIndex: 0))
        XCTAssertEqual(data.completedProblemsCount(day: 1, totalProblems: 5), 2)
        XCTAssertEqual(data.totalCompletedProblems(), 2)
    }

    func testCompletedTopicsCountUsesPlan() {
        var data = AppData()
        let day1Count = dsaPlan[0].problems.count
        for index in 0..<day1Count {
            data.progress["1-\(index)"] = true
        }

        XCTAssertEqual(data.completedTopicsCount(), 1)
    }

    func testTodayHabitsCount() {
        var data = AppData()
        let today = AppData.todayString()
        data.habits[today] = ["dsa": true, "exercise": false, "other": true]

        XCTAssertEqual(data.todayHabitsCount(), 2)
    }

    func testGetHabitStatusReturnsCorrectValue() {
        var data = AppData()
        let today = AppData.todayString()
        data.habits[today] = ["dsa": true, "exercise": false]

        XCTAssertTrue(data.getHabitStatus(habit: "dsa"))
        XCTAssertFalse(data.getHabitStatus(habit: "exercise"))
        XCTAssertFalse(data.getHabitStatus(habit: "other"))
    }

    func testTodayStringFormat() {
        let today = AppData.todayString()

        let parts = today.split(separator: "-")
        XCTAssertEqual(parts.count, 3, "Format should be yyyy-MM-dd")
        XCTAssertEqual(parts[0].count, 4, "Year should have 4 digits")
        XCTAssertEqual(parts[1].count, 2, "Month should have 2 digits")
        XCTAssertEqual(parts[2].count, 2, "Day should have 2 digits")
    }

    func testDecodingWithMissingFieldsUsesDefaults() throws {
        let json = """
        {"progress": {}, "habits": {}}
        """
        let data = try JSONDecoder().decode(AppData.self, from: Data(json.utf8))

        XCTAssertEqual(data.dayOffset, 0)
        XCTAssertEqual(data.leetCodeUsername, "ashim986")
        XCTAssertTrue(data.savedSolutions.isEmpty)
    }

    func testEncodingPreservesAllFields() throws {
        var data = AppData()
        data.progress["1-0"] = true
        data.habits["2026-02-04"] = ["dsa": true]
        data.dayOffset = 3
        data.leetCodeUsername = "testuser"
        data.savedSolutions["key|swift"] = "code"

        let encoded = try JSONEncoder().encode(data)
        let decoded = try JSONDecoder().decode(AppData.self, from: encoded)

        XCTAssertEqual(decoded.progress, data.progress)
        XCTAssertEqual(decoded.habits, data.habits)
        XCTAssertEqual(decoded.dayOffset, data.dayOffset)
        XCTAssertEqual(decoded.leetCodeUsername, data.leetCodeUsername)
        XCTAssertEqual(decoded.savedSolutions, data.savedSolutions)
    }
}
