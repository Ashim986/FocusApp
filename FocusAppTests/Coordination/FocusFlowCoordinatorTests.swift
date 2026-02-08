@testable import FocusApp
import XCTest

final class FocusFlowCoordinatorTests: XCTestCase {

    @MainActor
    func testInitialRouteIsRoot() {
        let sut = FocusFlowCoordinator(focusCoordinator: FocusCoordinator())
        XCTAssertEqual(sut.activeRoute, .root)
    }

    @MainActor
    func testFocusCoordinatorIsAccessible() {
        let focus = FocusCoordinator()
        let sut = FocusFlowCoordinator(focusCoordinator: focus)
        XCTAssertTrue(sut.focusCoordinator === focus)
    }
}
