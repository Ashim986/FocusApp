@testable import FocusApp
import XCTest

final class PlanFlowCoordinatorTests: XCTestCase {

    @MainActor
    private func makeSUT() -> PlanFlowCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        return PlanFlowCoordinator(container: AppContainer(appStore: store))
    }

    @MainActor
    func testInitialRouteIsRoot() {
        let sut = makeSUT()
        XCTAssertEqual(sut.activeRoute, .root)
    }

    @MainActor
    func testPopToRootReturnsToRoot() {
        let sut = makeSUT()
        sut.activeRoute = .codingDetail(problemSlug: "merge-intervals")
        sut.popToRoot()
        XCTAssertEqual(sut.activeRoute, .root)
    }
}
