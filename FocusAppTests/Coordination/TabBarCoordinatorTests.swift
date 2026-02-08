@testable import FocusApp
import SwiftUI
import XCTest

final class TabBarCoordinatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> TabBarCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        let container = AppContainer(appStore: store)
        let focusCoordinator = FocusCoordinator()
        return TabBarCoordinator(container: container, focusCoordinator: focusCoordinator)
    }

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsTabToday() {
        let sut = makeSUT()
        XCTAssertEqual(sut.activeRoute, .tab(.today))
    }

    @MainActor
    func testInitialSelectedTabIsToday() {
        let sut = makeSUT()
        XCTAssertEqual(sut.selectedTab, .today)
    }

    // MARK: - Tab Switching

    @MainActor
    func testSelectTabPlan() {
        let sut = makeSUT()
        sut.selectedTab = .plan
        XCTAssertEqual(sut.activeRoute, .tab(.plan))
        XCTAssertEqual(sut.selectedTab, .plan)
    }

    @MainActor
    func testSelectTabStats() {
        let sut = makeSUT()
        sut.selectedTab = .stats
        XCTAssertEqual(sut.activeRoute, .tab(.stats))
    }

    @MainActor
    func testSelectTabFocus() {
        let sut = makeSUT()
        sut.selectedTab = .focus
        XCTAssertEqual(sut.activeRoute, .tab(.focus))
    }

    @MainActor
    func testSelectTabCoding() {
        let sut = makeSUT()
        sut.selectedTab = .coding
        XCTAssertEqual(sut.activeRoute, .tab(.coding))
    }

    // MARK: - Settings

    @MainActor
    func testShowSettingsPresentsSettings() {
        let sut = makeSUT()
        sut.showSettings()
        XCTAssertTrue(sut.settingsCoordinator.isPresented)
    }

    @MainActor
    func testDismissSettingsClosesSettings() {
        let sut = makeSUT()
        sut.showSettings()
        sut.dismissSettings()
        XCTAssertFalse(sut.settingsCoordinator.isPresented)
    }

    // MARK: - Switch to Focus

    @MainActor
    func testSwitchToFocusChangesTab() {
        let sut = makeSUT()
        sut.selectedTab = .today
        sut.switchToFocus()
        XCTAssertEqual(sut.selectedTab, .focus)
    }

    // MARK: - Open Coding Detail

    @MainActor
    func testOpenCodingDetailSwitchesToCodingTab() {
        let sut = makeSUT()
        let problem = dsaPlan[0].problems[0]
        sut.openCodingDetail(problem: problem, day: 1, index: 0)
        XCTAssertEqual(sut.selectedTab, .coding)
    }

    @MainActor
    func testOpenCodingDetailPushesDetail() {
        let sut = makeSUT()
        let problem = dsaPlan[0].problems[0]
        sut.openCodingDetail(problem: problem, day: 1, index: 0)
        XCTAssertTrue(sut.codingFlow.isDetailShown)
    }

    // MARK: - Child Coordinators

    @MainActor
    func testChildCoordinatorCount() {
        let sut = makeSUT()
        // 5 flow coordinators + 1 settings coordinator = 6
        XCTAssertEqual(sut.childCoordinators.count, 6)
    }
}
