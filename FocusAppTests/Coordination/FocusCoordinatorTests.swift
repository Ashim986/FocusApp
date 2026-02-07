@testable import FocusApp
import XCTest

final class FocusCoordinatorTests: XCTestCase {

    // MARK: - Initial State

    @MainActor
    func testInitialRouteIsIdle() {
        let sut = FocusCoordinator()
        XCTAssertEqual(sut.activeRoute, .idle)
    }

    @MainActor
    func testInitialSessionIsNotActive() {
        let sut = FocusCoordinator()
        XCTAssertFalse(sut.isSessionActive)
    }

    // MARK: - Start Session

    @MainActor
    func testStartFocusSessionSetsRunningRoute() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        XCTAssertEqual(sut.activeRoute, .running)
    }

    @MainActor
    func testStartFocusSessionSetsPresenterDuration() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 45)
        XCTAssertEqual(sut.presenter.duration, 45)
    }

    @MainActor
    func testStartFocusSessionActivatesSession() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        XCTAssertTrue(sut.isSessionActive)
    }

    // MARK: - Pause / Resume

    @MainActor
    func testPauseSetsRouteToPaused() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.pause()
        XCTAssertEqual(sut.activeRoute, .paused)
        XCTAssertTrue(sut.isSessionActive)
    }

    @MainActor
    func testResumeSetsRouteToRunning() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.pause()
        sut.resume()
        XCTAssertEqual(sut.activeRoute, .running)
    }

    // MARK: - End Session

    @MainActor
    func testEndSessionSetsRouteToIdle() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.endSession()
        XCTAssertEqual(sut.activeRoute, .idle)
    }

    @MainActor
    func testEndSessionDeactivatesSession() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.endSession()
        XCTAssertFalse(sut.isSessionActive)
    }

    // MARK: - Reset Session

    @MainActor
    func testResetSessionSetsRouteToIdle() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.resetSession()
        XCTAssertEqual(sut.activeRoute, .idle)
    }

    // MARK: - isSessionActive

    @MainActor
    func testIsSessionActiveWhenRunning() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        XCTAssertTrue(sut.isSessionActive)
    }

    @MainActor
    func testIsSessionActiveWhenPaused() {
        let sut = FocusCoordinator()
        sut.startFocusSession(minutes: 25)
        sut.pause()
        XCTAssertTrue(sut.isSessionActive)
    }

    @MainActor
    func testIsSessionNotActiveWhenIdle() {
        let sut = FocusCoordinator()
        XCTAssertFalse(sut.isSessionActive)
    }

    @MainActor
    func testIsSessionNotActiveWhenCompleted() {
        let sut = FocusCoordinator()
        sut.activeRoute = .completed
        XCTAssertFalse(sut.isSessionActive)
    }

    // MARK: - State Machine Transitions

    @MainActor
    func testFullLifecycle() {
        let sut = FocusCoordinator()

        // idle → running
        XCTAssertEqual(sut.activeRoute, .idle)
        sut.startFocusSession(minutes: 10)
        XCTAssertEqual(sut.activeRoute, .running)

        // running → paused
        sut.pause()
        XCTAssertEqual(sut.activeRoute, .paused)

        // paused → running
        sut.resume()
        XCTAssertEqual(sut.activeRoute, .running)

        // running → ended (idle)
        sut.endSession()
        XCTAssertEqual(sut.activeRoute, .idle)
    }
}
