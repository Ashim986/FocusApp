@testable import FocusApp
import XCTest

final class TodayInteractorTests: XCTestCase {
    @MainActor
    func testToggleProblemUpdatesAppStore() {
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

        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))

        interactor.toggleProblem(day: 1, problemIndex: 0)

        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
    }

    @MainActor
    func testToggleHabitUpdatesAppStore() {
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

        XCTAssertFalse(store.data.getHabitStatus(habit: "dsa"))

        interactor.toggleHabit("dsa")

        XCTAssertTrue(store.data.getHabitStatus(habit: "dsa"))
    }

    @MainActor
    func testAdvanceToNextDayUpdatesAppStore() {
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

        let initialDay = store.currentDayNumber()

        interactor.advanceToNextDay()

        XCTAssertEqual(store.currentDayNumber(), initialDay + 1)
    }

    @MainActor
    func testCurrentDayNumberReturnsCorrectDay() {
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

        XCTAssertEqual(interactor.currentDayNumber(), 1)

        store.advanceToNextDay()

        XCTAssertEqual(interactor.currentDayNumber(), 2)
    }

    @MainActor
    func testToggleHabitSendsCelebrationOnAllComplete() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        notificationManager.authorizationStatus = true
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )

        // Complete all but one habit
        store.toggleHabit("dsa")
        store.toggleHabit("exercise")

        // Complete the last habit
        interactor.toggleHabit("other")

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.allHabitsCelebrationCalled)
    }

    @MainActor
    func testToggleProblemSendsCelebrationOnTopicComplete() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        notificationManager.authorizationStatus = true
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )

        // Complete all but one problem in day 1
        for i in 0..<8 {
            store.toggleProblem(day: 1, problemIndex: i)
        }

        // Complete the last problem
        interactor.toggleProblem(day: 1, problemIndex: 8)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.topicCompleteCelebrationCalled)
        XCTAssertEqual(notificationManager.lastCelebrationTopic, "Priority Sprint I")
    }
}

@MainActor
private func makeLeetCodeSync(store: AppStateStore) -> LeetCodeSyncInteractor {
    LeetCodeSyncInteractor(appStore: store, client: FakeLeetCodeClient())
}
