@testable import FocusApp
import XCTest

final class PlanPresenterTests: XCTestCase {
    @MainActor
    func testInitialDaysMatchDSAPlan() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        // Allow binding to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.days.count, dsaPlan.count)
        XCTAssertEqual(presenter.days[0].topic, "Priority Sprint I")
        XCTAssertEqual(presenter.days[1].topic, "Priority Sprint II")
        XCTAssertEqual(presenter.days.last?.topic, "1-D DP (cont.) + 2-D DP Intro")
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
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        presenter.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testDaysUpdateWhenDataChanges() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Initially no problems completed
        XCTAssertEqual(presenter.days[0].completedCount, 0)

        // Complete a problem
        store.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.days[0].completedCount, 1)
    }

    @MainActor
    func testDayViewModelShowsCorrectCompletedCount() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        // Complete 3 problems in day 1
        store.toggleProblem(day: 1, problemIndex: 0)
        store.toggleProblem(day: 1, problemIndex: 1)
        store.toggleProblem(day: 1, problemIndex: 2)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.days[0].completedCount, 3)
        XCTAssertFalse(presenter.days[0].isFullyCompleted)
    }

    @MainActor
    func testProblemViewModelShowsCorrectCompletionStatus() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Initially not completed
        XCTAssertFalse(presenter.days[0].problems[0].isCompleted)

        // Complete the problem
        store.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(presenter.days[0].problems[0].isCompleted)
    }
}

@MainActor
private func makeLeetCodeSync(store: AppStateStore) -> LeetCodeSyncInteractor {
    LeetCodeSyncInteractor(appStore: store, client: FakeLeetCodeClient())
}
