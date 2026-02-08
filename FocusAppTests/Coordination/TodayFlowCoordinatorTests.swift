@testable import FocusApp
import XCTest

final class TodayFlowCoordinatorTests: XCTestCase {

    @MainActor
    private func makeSUT() -> TodayFlowCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        return TodayFlowCoordinator(container: AppContainer(appStore: store))
    }

    @MainActor
    func testInitialRouteIsRoot() {
        let sut = makeSUT()
        XCTAssertEqual(sut.activeRoute, .root)
    }

    @MainActor
    func testPopToRootReturnsToRoot() {
        let sut = makeSUT()
        sut.activeRoute = .codingDetail(problemSlug: "two-sum")
        sut.popToRoot()
        XCTAssertEqual(sut.activeRoute, .root)
    }
}
