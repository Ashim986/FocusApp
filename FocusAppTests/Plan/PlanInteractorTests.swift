@testable import FocusApp
import XCTest

final class PlanInteractorTests: XCTestCase {
    @MainActor
    func testToggleProblemUpdatesAppStore() {
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

        XCTAssertFalse(store.isProblemCompleted(day: 1, problemIndex: 0))

        interactor.toggleProblem(day: 1, problemIndex: 0)

        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
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
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )

        // Complete all but one problem in day 1
        for i in 0..<10 {
            store.toggleProblem(day: 1, problemIndex: i)
        }

        // Complete the last problem
        interactor.toggleProblem(day: 1, problemIndex: 10)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertTrue(notificationManager.topicCompleteCelebrationCalled)
        XCTAssertEqual(notificationManager.lastCelebrationTopic, "Priority Sprint I")
    }

    @MainActor
    func testToggleProblemDoesNotSendCelebrationOnPartialComplete() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        notificationManager.authorizationStatus = true
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )

        // Complete only one problem
        interactor.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(notificationManager.topicCompleteCelebrationCalled)
    }

    @MainActor
    func testDataPublisherExposesAppStoreData() async {
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

        var receivedData: AppData?
        let cancellable = interactor.dataPublisher
            .sink { data in
                receivedData = data
            }

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(receivedData)
        cancellable.cancel()
    }
}

@MainActor
private func makeLeetCodeSync(store: AppStateStore) -> LeetCodeSyncInteractor {
    LeetCodeSyncInteractor(appStore: store, client: FakeLeetCodeClient())
}
