@testable import FocusApp
import XCTest

final class StatsFlowCoordinatorTests: XCTestCase {

    @MainActor
    func testInitialRouteIsRoot() {
        let sut = StatsFlowCoordinator()
        XCTAssertEqual(sut.activeRoute, .root)
    }

    @MainActor
    func testPopToRootReturnsToRoot() {
        let sut = StatsFlowCoordinator()
        sut.activeRoute = .codingDetail(problemSlug: "valid-anagram")
        sut.popToRoot()
        XCTAssertEqual(sut.activeRoute, .root)
    }
}
