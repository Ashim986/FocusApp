@testable import FocusApp
import XCTest

final class StatsInteractorTests: XCTestCase {
    @MainActor
    func testDataSnapshotReturnsCurrentData() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)

        // Initial snapshot
        let snapshot1 = interactor.dataSnapshot()
        XCTAssertEqual(snapshot1.totalCompletedProblems(), 0)

        // Modify store
        store.toggleProblem(day: 1, problemIndex: 0)

        // New snapshot should reflect changes
        let snapshot2 = interactor.dataSnapshot()
        XCTAssertEqual(snapshot2.totalCompletedProblems(), 1)
    }

    @MainActor
    func testDataPublisherExposesAppStoreData() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)

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
