@testable import FocusApp
import SwiftUI
import XCTest

final class CodingFlowCoordinatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> CodingFlowCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        let container = AppContainer(appStore: store)
        return CodingFlowCoordinator(container: container)
    }

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsRoot() {
        let sut = makeSUT()
        XCTAssertEqual(sut.activeRoute, .root)
    }

    @MainActor
    func testInitialIsDetailShownIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isDetailShown)
    }

    // MARK: - Push / Pop

    @MainActor
    func testPushCodingDetailSetsDetailRoute() {
        let sut = makeSUT()
        sut.pushCodingDetail(problemSlug: "two-sum")
        XCTAssertEqual(sut.activeRoute, .codingDetail(problemSlug: "two-sum"))
        XCTAssertTrue(sut.isDetailShown)
    }

    @MainActor
    func testPopToListReturnsToRoot() {
        let sut = makeSUT()
        sut.pushCodingDetail(problemSlug: "two-sum")
        sut.popToList()
        XCTAssertEqual(sut.activeRoute, .root)
        XCTAssertFalse(sut.isDetailShown)
    }

    // MARK: - Open Problem

    @MainActor
    func testOpenProblemSetsDetailRoute() {
        let sut = makeSUT()
        let problem = dsaPlan[0].problems[0]
        sut.openProblem(problem: problem, day: 1, index: 0)
        XCTAssertTrue(sut.isDetailShown)
    }

    @MainActor
    func testOpenProblemResetsCodingCoordinator() {
        let sut = makeSUT()

        // Set some state
        sut.codingCoordinator.isProblemSidebarShown = true
        sut.codingCoordinator.isProblemPickerShown = true
        sut.codingCoordinator.activeSheet = .debugLogs

        // Open a problem
        let problem = dsaPlan[0].problems[0]
        sut.openProblem(problem: problem, day: 1, index: 0)

        // Coding coordinator should be reset
        XCTAssertFalse(sut.codingCoordinator.isProblemSidebarShown)
        XCTAssertFalse(sut.codingCoordinator.isProblemPickerShown)
        XCTAssertNil(sut.codingCoordinator.activeSheet)
    }

    // MARK: - Child Coordinators

    @MainActor
    func testCodingCoordinatorIsChild() {
        let sut = makeSUT()
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }
}
