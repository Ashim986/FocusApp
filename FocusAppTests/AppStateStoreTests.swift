@testable import FocusApp
import XCTest

@MainActor
final class AppStateStoreTests: XCTestCase {
    func testToggleProblemUpdatesProgress() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )

        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))
        store.toggleProblem(day: 1, problemIndex: 0)
        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
        store.toggleProblem(day: 1, problemIndex: 0)
        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    func testToggleHabitUpdatesToday() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )

        XCTAssertFalse(store.isHabitDone("dsa"))
        store.toggleHabit("dsa")
        XCTAssertTrue(store.isHabitDone("dsa"))
    }

    func testUpdateLeetCodeUsernameTrims() {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)

        store.updateLeetCodeUsername("  newUser  ")
        XCTAssertEqual(store.data.leetCodeUsername, "newUser")
    }

    func testSaveSolutionClearsWhenBlank() {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)

        store.saveSolution(code: "print(1)", for: "key")
        XCTAssertEqual(store.solutionCode(for: "key"), "print(1)")

        store.saveSolution(code: "  ", for: "key")
        XCTAssertNil(store.solutionCode(for: "key"))
    }

    func testAdvanceToNextDayMovesForward() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )

        XCTAssertEqual(store.currentDayNumber(), 1)
        store.advanceToNextDay()
        XCTAssertEqual(store.currentDayNumber(), 2)
    }

    func testApplySolvedSlugsMarksProgress() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )

        let slug = "reverse-linked-list"
        let result = store.applySolvedSlugs([slug])

        XCTAssertEqual(result.syncedCount, 1)
        XCTAssertEqual(result.totalMatched, 1)
        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    func testTodaysTopicUsesPlan() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )

        XCTAssertEqual(store.todaysTopic(), "Linked List")
    }

    func testReloadUsesStorage() {
        struct ReloadStorage: AppStorage {
            var stored: AppData
            func load() -> AppData { stored }
            func save(_ data: AppData) { }
        }
        var data = AppData()
        data.leetCodeUsername = "reloadUser"
        let storage = ReloadStorage(stored: data)
        let store = AppStateStore(storage: storage)

        store.reload()

        XCTAssertEqual(store.data.leetCodeUsername, "reloadUser")
    }
}
