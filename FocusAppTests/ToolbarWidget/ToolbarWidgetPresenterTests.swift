@testable import FocusApp
import XCTest

final class ToolbarWidgetPresenterTests: XCTestCase {
    @MainActor
    func testTotalProblemsCalculatesFromDSAPlan() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        let expectedTotal = dsaPlan.reduce(0) { $0 + $1.problems.count }
        XCTAssertEqual(presenter.totalProblems, expectedTotal)
    }

    @MainActor
    func testSolvedProblemsReflectsData() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        XCTAssertEqual(presenter.solvedProblems, 0)

        store.toggleProblem(day: 1, problemIndex: 0)
        store.toggleProblem(day: 1, problemIndex: 1)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.solvedProblems, 2)
    }

    @MainActor
    func testProgressPercentageCalculatesCorrectly() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        // Mark 5 problems as solved
        for i in 0..<5 {
            store.toggleProblem(day: 1, problemIndex: i)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        let expectedPercent = Double(5) / Double(presenter.totalProblems) * 100
        XCTAssertEqual(presenter.progressPercentage, expectedPercent, accuracy: 0.01)
    }

    @MainActor
    func testSyncNowTriggersInteractorSync() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let initialData = AppData()
        let store = AppStateStore(
            storage: InMemoryAppStorage(initial: initialData),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.solvedSlugsResult = .success(["reverse-linked-list"])
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.syncNow()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(presenter.isSyncing)
    }

    @MainActor
    func testSyncNowUpdatesLastSyncResult() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let initialData = AppData()
        let store = AppStateStore(
            storage: InMemoryAppStorage(initial: initialData),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.solvedSlugsResult = .success(["reverse-linked-list"])
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.syncNow()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(presenter.lastSyncResult.isEmpty)
    }

    @MainActor
    func testSyncNowShowsSyncingState() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let initialData = AppData()
        let store = AppStateStore(
            storage: InMemoryAppStorage(initial: initialData),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        XCTAssertFalse(presenter.isSyncing)

        presenter.syncNow()

        // Should be syncing immediately after call
        XCTAssertTrue(presenter.isSyncing)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(presenter.isSyncing)
    }

    @MainActor
    func testSyncNowGuardsEmptyUsername() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        var initialData = AppData()
        initialData.leetCodeUsername = ""
        let store = AppStateStore(
            storage: InMemoryAppStorage(initial: initialData),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.syncNow()

        XCTAssertEqual(presenter.lastSyncResult, "Set username in Settings")
        XCTAssertFalse(presenter.isSyncing)
    }

    @MainActor
    func testToggleHabitCallsInteractor() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.toggleHabit("dsa")

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(store.data.getHabitStatus(habit: "dsa"))
    }

    @MainActor
    func testToggleProblemCallsInteractor() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testAdvanceToNextDayCallsInteractor() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        let initialDay = store.currentDayNumber()

        presenter.advanceToNextDay()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(store.currentDayNumber(), initialDay + 1)
    }

    @MainActor
    func testValidateAndSaveUsernameUpdatesState() async {
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
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        presenter.editingUsername = "testuser"
        presenter.validateAndSaveUsername()

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(presenter.usernameValidationState, .valid)
    }

    @MainActor
    func testCarryoverProblemsShowsIncompleteOnly() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: store, client: client)
        let interactor = ToolbarWidgetInteractor(appStore: store, leetCodeSync: syncInteractor)
        let presenter = ToolbarWidgetPresenter(interactor: interactor)

        // Initially all 11 problems should be carryover (incomplete)
        XCTAssertEqual(presenter.carryoverProblems.count, 11)

        // Complete 2 problems
        store.toggleProblem(day: 1, problemIndex: 0)
        store.toggleProblem(day: 1, problemIndex: 1)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should have 9 carryover problems
        XCTAssertEqual(presenter.carryoverProblems.count, 9)
    }
}
