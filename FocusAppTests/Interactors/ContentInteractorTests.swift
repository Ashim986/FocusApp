@testable import FocusApp
import XCTest

final class ContentInteractorTests: XCTestCase {
    @MainActor
    func testDataPublisherExposesAppStoreData() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)

        var receivedData: AppData?
        let cancellable = interactor.dataPublisher
            .sink { data in
                receivedData = data
            }

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertNotNil(receivedData)
        cancellable.cancel()
    }

    @MainActor
    func testDataPublisherUpdatesOnChange() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)

        var updateCount = 0
        let cancellable = interactor.dataPublisher
            .sink { _ in
                updateCount += 1
            }

        try? await Task.sleep(nanoseconds: 50_000_000)
        let initialCount = updateCount

        // Trigger a change
        store.toggleProblem(day: 1, problemIndex: 0)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertGreaterThan(updateCount, initialCount)
        cancellable.cancel()
    }
}
