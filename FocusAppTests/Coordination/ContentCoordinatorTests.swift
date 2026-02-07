@testable import FocusApp
import SwiftUI
import XCTest

final class ContentCoordinatorTests: XCTestCase {

    // MARK: - Helpers

    @MainActor
    private func makeSUT() -> ContentCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        let container = AppContainer(appStore: store)
        return ContentCoordinator(container: container)
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

    @MainActor
    func testInitialIsCodingPresentedIsFalse() {
        let sut = makeSUT()
        XCTAssertFalse(sut.isCodingPresented)
    }

    // MARK: - Tab Switching

    @MainActor
    func testSelectTabPlan() {
        let sut = makeSUT()
        sut.selectTab(.plan)

        XCTAssertEqual(sut.activeRoute, .tab(.plan))
        XCTAssertEqual(sut.selectedTab, .plan)
        XCTAssertFalse(sut.isCodingPresented)
    }

    @MainActor
    func testSelectTabStats() {
        let sut = makeSUT()
        sut.selectTab(.stats)

        XCTAssertEqual(sut.activeRoute, .tab(.stats))
        XCTAssertEqual(sut.selectedTab, .stats)
    }

    @MainActor
    func testSelectedTabSetterUpdatesRoute() {
        let sut = makeSUT()
        sut.selectedTab = .plan

        XCTAssertEqual(sut.activeRoute, .tab(.plan))
    }

    // MARK: - Coding Environment

    @MainActor
    func testOpenCodingEnvironmentSetsCodingRoute() {
        let sut = makeSUT()
        let problem = dsaPlan[0].problems[0]
        sut.openCodingEnvironment(problem: problem, day: 1, index: 0)

        XCTAssertEqual(sut.activeRoute, .coding(.editor))
        XCTAssertTrue(sut.isCodingPresented)
    }

    @MainActor
    func testOpenCodingEnvironmentGenericSetsCodingRoute() {
        let sut = makeSUT()
        sut.openCodingEnvironmentGeneric()

        XCTAssertEqual(sut.activeRoute, .coding(.editor))
        XCTAssertTrue(sut.isCodingPresented)
    }

    @MainActor
    func testCloseCodingEnvironmentReturnsToPreviousTab() {
        let sut = makeSUT()

        // Start on stats tab
        sut.selectTab(.stats)
        XCTAssertEqual(sut.selectedTab, .stats)

        // Open coding environment
        sut.openCodingEnvironmentGeneric()
        XCTAssertTrue(sut.isCodingPresented)

        // Close coding environment — should return to stats
        sut.closeCodingEnvironment()
        XCTAssertFalse(sut.isCodingPresented)
        XCTAssertEqual(sut.activeRoute, .tab(.stats))
        XCTAssertEqual(sut.selectedTab, .stats)
    }

    @MainActor
    func testCloseCodingEnvironmentDefaultsToTodayWhenNoTabSet() {
        let sut = makeSUT()

        // Open coding without switching tab first
        sut.openCodingEnvironmentGeneric()
        sut.closeCodingEnvironment()

        XCTAssertEqual(sut.selectedTab, .today)
    }

    @MainActor
    func testOpenCodingEnvironmentResetsCodingCoordinator() {
        let sut = makeSUT()
        let coding = sut.codingCoordinator

        // Set some state on the coding coordinator
        coding.isProblemSidebarShown = true
        coding.isProblemPickerShown = true
        coding.activeSheet = .debugLogs

        // Open coding environment
        let problem = dsaPlan[0].problems[0]
        sut.openCodingEnvironment(problem: problem, day: 1, index: 0)

        // Coding coordinator should be reset
        XCTAssertFalse(coding.isProblemSidebarShown)
        XCTAssertFalse(coding.isProblemPickerShown)
        XCTAssertNil(coding.activeSheet)
    }

    // MARK: - Child Coordinators

    @MainActor
    func testCodingCoordinatorIsChild() {
        let sut = makeSUT()
        XCTAssertEqual(sut.childCoordinators.count, 1)
    }

    // MARK: - Platform Helpers

    @MainActor
    func testColumnVisibilityWhenNotCoding() {
        let sut = makeSUT()
        XCTAssertEqual(sut.columnVisibility, .automatic)
    }

    @MainActor
    func testColumnVisibilityWhenCoding() {
        let sut = makeSUT()
        sut.openCodingEnvironmentGeneric()
        XCTAssertEqual(sut.columnVisibility, .doubleColumn)
    }

    // MARK: - Tab Persistence Through Coding

    @MainActor
    func testTabPersistsThroughCodingRoundTrip() {
        let sut = makeSUT()

        // Select plan tab
        sut.selectTab(.plan)

        // Open and close coding
        sut.openCodingEnvironmentGeneric()
        sut.closeCodingEnvironment()

        // Should return to plan
        XCTAssertEqual(sut.selectedTab, .plan)
    }

    @MainActor
    func testMultipleCodingRoundTripsPreserveLastTab() {
        let sut = makeSUT()

        // First: stats tab → coding → close
        sut.selectTab(.stats)
        sut.openCodingEnvironmentGeneric()
        sut.closeCodingEnvironment()
        XCTAssertEqual(sut.selectedTab, .stats)

        // Second: plan tab → coding → close
        sut.selectTab(.plan)
        sut.openCodingEnvironmentGeneric()
        sut.closeCodingEnvironment()
        XCTAssertEqual(sut.selectedTab, .plan)
    }
}
