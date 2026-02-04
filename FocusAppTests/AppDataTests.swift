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
}
