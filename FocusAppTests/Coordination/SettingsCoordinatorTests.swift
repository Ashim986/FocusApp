@testable import FocusApp
import SwiftUI
import XCTest

final class SettingsCoordinatorTests: XCTestCase {

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsClosed() {
        let sut = SettingsCoordinator()
        XCTAssertEqual(sut.activeRoute, .closed)
    }

    @MainActor
    func testInitialIsPresentedIsFalse() {
        let sut = SettingsCoordinator()
        XCTAssertFalse(sut.isPresented)
    }

    // MARK: - Present / Dismiss

    @MainActor
    func testPresentSetsRouteToPresented() {
        let sut = SettingsCoordinator()
        sut.present()
        XCTAssertEqual(sut.activeRoute, .presented)
        XCTAssertTrue(sut.isPresented)
    }

    @MainActor
    func testDismissSetsRouteToClosed() {
        let sut = SettingsCoordinator()
        sut.present()
        sut.dismiss()
        XCTAssertEqual(sut.activeRoute, .closed)
        XCTAssertFalse(sut.isPresented)
    }

    // MARK: - isPresentedBinding

    @MainActor
    func testIsPresentedBindingGetReflectsState() {
        let sut = SettingsCoordinator()
        XCTAssertFalse(sut.isPresentedBinding.wrappedValue)

        sut.present()
        XCTAssertTrue(sut.isPresentedBinding.wrappedValue)
    }

    @MainActor
    func testIsPresentedBindingSetUpdatesRoute() {
        let sut = SettingsCoordinator()

        // Set to true via binding
        sut.isPresentedBinding.wrappedValue = true
        XCTAssertEqual(sut.activeRoute, .presented)

        // Set to false via binding (simulates swipe-to-dismiss)
        sut.isPresentedBinding.wrappedValue = false
        XCTAssertEqual(sut.activeRoute, .closed)
    }
}
