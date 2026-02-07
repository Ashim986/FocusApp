@testable import FocusApp
import XCTest

final class WidgetCoordinatorTests: XCTestCase {

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsMain() {
        let coordinator = makeWidgetCoordinator()
        XCTAssertEqual(coordinator.activeRoute, .main)
    }

    @MainActor
    func testInitialVisibilityIsFalse() {
        let coordinator = makeWidgetCoordinator()
        XCTAssertFalse(coordinator.isVisible)
    }

    // MARK: - Toggle

    @MainActor
    func testToggleShowsWidget() {
        let coordinator = makeWidgetCoordinator()
        coordinator.toggle()
        XCTAssertTrue(coordinator.isVisible)
    }

    @MainActor
    func testToggleTwiceHidesWidget() {
        let coordinator = makeWidgetCoordinator()
        coordinator.toggle()
        coordinator.toggle()
        XCTAssertFalse(coordinator.isVisible)
    }

    // MARK: - Show / Hide

    @MainActor
    func testShowSetsVisible() {
        let coordinator = makeWidgetCoordinator()
        coordinator.show()
        XCTAssertTrue(coordinator.isVisible)
    }

    @MainActor
    func testShowIsIdempotent() {
        let coordinator = makeWidgetCoordinator()
        coordinator.show()
        coordinator.show()
        XCTAssertTrue(coordinator.isVisible)
    }

    @MainActor
    func testHideResetsVisible() {
        let coordinator = makeWidgetCoordinator()
        coordinator.show()
        coordinator.hide()
        XCTAssertFalse(coordinator.isVisible)
    }

    @MainActor
    func testHideWhenAlreadyHiddenIsNoOp() {
        let coordinator = makeWidgetCoordinator()
        coordinator.hide()
        XCTAssertFalse(coordinator.isVisible)
    }

    // MARK: - Section Navigation

    @MainActor
    func testShowSettings() {
        let coordinator = makeWidgetCoordinator()
        coordinator.showSettings()
        XCTAssertEqual(coordinator.activeRoute, .settings)
    }

    @MainActor
    func testShowTomorrow() {
        let coordinator = makeWidgetCoordinator()
        coordinator.showTomorrow()
        XCTAssertEqual(coordinator.activeRoute, .tomorrow)
    }

    @MainActor
    func testShowMain() {
        let coordinator = makeWidgetCoordinator()
        coordinator.showSettings()
        coordinator.showMain()
        XCTAssertEqual(coordinator.activeRoute, .main)
    }

    // MARK: - Helpers

    @MainActor
    private func makeWidgetCoordinator() -> WidgetCoordinator {
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: makeDate(year: 2026, month: 2, day: 3)),
            dateProvider: FixedDateProvider(date: makeDate(year: 2026, month: 2, day: 3))
        )
        let container = AppContainer(appStore: store)
        return WidgetCoordinator(presenter: container.toolbarWidgetPresenter)
    }
}
