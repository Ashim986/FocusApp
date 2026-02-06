@testable import FocusApp
import XCTest

@MainActor
final class AppStateStoreTests: XCTestCase {
    private func makeStore(
        start: Date,
        today: Date,
        initialData: AppData = AppData()
    ) -> AppStateStore {
        var data = initialData
        data.planStartDate = start
        let storage = InMemoryAppStorage(initial: data)
        return AppStateStore(
            storage: storage,
            calendar: Calendar.current,
            dateProvider: FixedDateProvider(date: today)
        )
    }

    func testToggleProblemUpdatesProgress() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = makeStore(start: start, today: start)

        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))
        store.toggleProblem(day: 1, problemIndex: 0)
        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
        store.toggleProblem(day: 1, problemIndex: 0)
        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    func testToggleHabitUpdatesToday() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = makeStore(start: start, today: start)

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
        let store = makeStore(start: start, today: start)

        XCTAssertEqual(store.currentDayNumber(), 1)
        store.advanceToNextDay()
        XCTAssertEqual(store.currentDayNumber(), 2)
    }

    func testApplySolvedSlugsMarksProgress() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = makeStore(start: start, today: start)

        let slug = "reverse-linked-list"
        let result = store.applySolvedSlugs([slug])

        let expectedMatches = dsaPlan.flatMap { day in
            day.problems.enumerated().compactMap { index, problem -> (Int, Int)? in
                guard let problemSlug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
                      problemSlug == slug else { return nil }
                return (day.id, index)
            }
        }

        XCTAssertEqual(result.syncedCount, expectedMatches.count)
        XCTAssertEqual(result.totalMatched, expectedMatches.count)
        XCTAssertFalse(expectedMatches.isEmpty)
        for match in expectedMatches {
            XCTAssertTrue(store.isProblemCompleted(day: match.0, problemIndex: match.1))
        }
    }

    func testTodaysTopicUsesPlan() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = makeStore(start: start, today: start)

        XCTAssertEqual(store.todaysTopic(), "Priority Sprint I")
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

    func testSavePersistsToStorage() {
        final class SpyStorage: AppStorage {
            var saved: AppData?
            func load() -> AppData { AppData() }
            func save(_ data: AppData) { saved = data }
        }
        let storage = SpyStorage()
        let store = AppStateStore(storage: storage)

        store.toggleProblem(day: 1, problemIndex: 0)

        XCTAssertNotNil(storage.saved)
        XCTAssertTrue(storage.saved?.progress["1-0"] == true)
    }

    func testCurrentDayNumberClampsToPlanCount() {
        let start = makeDate(year: 2026, month: 1, day: 1)
        let farFuture = makeDate(year: 2026, month: 12, day: 31)
        let store = makeStore(start: start, today: farFuture)

        XCTAssertEqual(store.currentDayNumber(), dsaPlan.count)
    }

    func testCurrentDayNumberClampsTo1() {
        let start = makeDate(year: 2026, month: 2, day: 10)
        let past = makeDate(year: 2026, month: 1, day: 1)
        let store = makeStore(start: start, today: past)

        XCTAssertEqual(store.currentDayNumber(), 1)
    }

    func testTodaysTopicForLastDay() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        var data = AppData()
        data.dayOffset = dsaPlan.count - 1
        let store = makeStore(start: start, today: start, initialData: data)

        XCTAssertEqual(store.currentDayNumber(), dsaPlan.count)
        XCTAssertEqual(store.todaysTopic(), "1-D DP (cont.) + 2-D DP Intro")
    }

    func testApplySolvedSlugsWithNoMatches() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = makeStore(start: start, today: start)

        let result = store.applySolvedSlugs(["non-existent-slug", "another-fake-slug"])

        XCTAssertEqual(result.syncedCount, 0)
        XCTAssertEqual(result.totalMatched, 0)
    }

    func testApplySolvedSlugsWithAllAlreadySolved() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        var data = AppData()
        let slug = "reverse-linked-list"
        let matches = dsaPlan.flatMap { day in
            day.problems.enumerated().compactMap { index, problem -> String? in
                guard let problemSlug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
                      problemSlug == slug else { return nil }
                return "\(day.id)-\(index)"
            }
        }
        for key in matches {
            data.progress[key] = true
        }
        let store = makeStore(start: start, today: start, initialData: data)

        let result = store.applySolvedSlugs([slug])

        XCTAssertEqual(result.syncedCount, 0)
        XCTAssertEqual(result.totalMatched, matches.count)
    }
}
