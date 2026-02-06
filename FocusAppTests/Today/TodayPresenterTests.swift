@testable import FocusApp
import XCTest

final class TodayPresenterTests: XCTestCase {
    @MainActor
    func testInitialVisibleDaysShowsCurrentAndCarryover() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // On day 1, should only show day 1
        XCTAssertEqual(presenter.visibleDays.count, 1)
        XCTAssertEqual(presenter.visibleDays[0].id, 1)
        XCTAssertTrue(presenter.visibleDays[0].isToday)
    }

    @MainActor
    func testToggleHabitCallsInteractor() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

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
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

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
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        let initialDay = store.currentDayNumber()

        presenter.advanceToNextDay()

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(store.currentDayNumber(), initialDay + 1)
    }

    @MainActor
    func testHabitsViewModelShowsThreeHabits() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.habits.count, 3)
        XCTAssertEqual(presenter.habits[0].id, "dsa")
        XCTAssertEqual(presenter.habits[1].id, "exercise")
        XCTAssertEqual(presenter.habits[2].id, "other")
    }

    @MainActor
    func testHabitsCompletedCountUpdatesOnToggle() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.habitsCompletedCount, 0)

        presenter.toggleHabit("dsa")
        presenter.toggleHabit("exercise")

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.habitsCompletedCount, 2)
    }

    @MainActor
    func testCarryoverProblemsAppearWhenIncomplete() async throws {
        let start = makeDate(year: 2026, month: 2, day: 3)
        // Move to day 2 so day 1 becomes a past day
        let day2 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 1, to: start))
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: day2)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        // Leave day 1 problems incomplete (carryover)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Should show day 1 (with carryover) and day 2 (today)
        XCTAssertEqual(presenter.visibleDays.count, 2)
        XCTAssertEqual(presenter.visibleDays[0].id, 1)
        XCTAssertFalse(presenter.visibleDays[0].isToday)
        XCTAssertEqual(presenter.visibleDays[1].id, 2)
        XCTAssertTrue(presenter.visibleDays[1].isToday)
    }

    @MainActor
    func testCompletedPastDaysAreHidden() async throws {
        let start = makeDate(year: 2026, month: 2, day: 3)
        // Move to day 2 so day 1 becomes a past day
        let day2 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 1, to: start))
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: day2)
        )

        // Complete all problems in day 1
        for problemIndex in 0..<11 {
            store.toggleProblem(day: 1, problemIndex: problemIndex)
        }

        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Only day 2 (today) should be visible since day 1 is fully completed
        XCTAssertEqual(presenter.visibleDays.count, 1)
        XCTAssertEqual(presenter.visibleDays[0].id, 2)
        XCTAssertTrue(presenter.visibleDays[0].isToday)
    }
}

@MainActor
private func makeLeetCodeSync(store: AppStateStore) -> LeetCodeSyncInteractor {
    LeetCodeSyncInteractor(appStore: store, client: FakeLeetCodeClient())
}
