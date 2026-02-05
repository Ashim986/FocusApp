@testable import FocusApp
import XCTest

final class ToolbarWidgetInteractorTests: XCTestCase {
    @MainActor
    func testToggleHabitDelegatesToAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        XCTAssertFalse(store.data.getHabitStatus(habit: "dsa"))

        interactor.toggleHabit("dsa")

        XCTAssertTrue(store.data.getHabitStatus(habit: "dsa"))
    }

    @MainActor
    func testToggleProblemDelegatesToAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))

        interactor.toggleProblem(day: 1, problemIndex: 0)

        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testAdvanceToNextDayDelegatesToAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        let initialDay = store.currentDayNumber()

        interactor.advanceToNextDay()

        XCTAssertEqual(store.currentDayNumber(), initialDay + 1)
    }

    @MainActor
    func testCurrentDayNumberReturnsFromAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        XCTAssertEqual(interactor.currentDayNumber(), 1)

        store.advanceToNextDay()

        XCTAssertEqual(interactor.currentDayNumber(), 2)
    }

    @MainActor
    func testTodaysTopicReturnsFromAppStore() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        XCTAssertEqual(interactor.todaysTopic(), "Linked List")
    }

    @MainActor
    func testValidateAndSaveUsernameValidatesFirst() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.validateResult = .success(true)
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        let result = await interactor.validateAndSaveUsername("testuser")

        XCTAssertTrue(result)
        XCTAssertEqual(store.data.leetCodeUsername, "testuser")
    }

    @MainActor
    func testValidateAndSaveUsernameSyncsAfterSave() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.validateResult = .success(true)
        client.solvedSlugsResult = .success(["reverse-linked-list"])
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        _ = await interactor.validateAndSaveUsername("testuser")

        // Verify sync was called by checking if problems were synced
        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testSyncSolvedProblemsDelegatesToLeetCodeSync() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.solvedSlugsResult = .success(["reverse-linked-list"])
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)

        let result = await interactor.syncSolvedProblems(username: "testuser")

        XCTAssertEqual(result.syncedCount, 1)
    }
}
