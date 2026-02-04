@testable import FocusApp
import XCTest

final class FocusPresenterTests: XCTestCase {
    @MainActor
    func testStartTimerSetsCorrectValues() {
        let presenter = FocusPresenter()
        presenter.duration = 30

        presenter.startTimer()

        XCTAssertEqual(presenter.totalTime, 30 * 60)
        XCTAssertEqual(presenter.timeRemaining, 30 * 60)
        XCTAssertTrue(presenter.isRunning)
        XCTAssertTrue(presenter.hasStarted)
        XCTAssertFalse(presenter.isPaused)
        XCTAssertFalse(presenter.isCompleted)
    }

    @MainActor
    func testStartTimerClampsMinimumDuration() {
        let presenter = FocusPresenter()
        presenter.duration = 0

        presenter.startTimer()

        XCTAssertEqual(presenter.totalTime, 60)
        XCTAssertEqual(presenter.timeRemaining, 60)
    }

    @MainActor
    func testHandleTickDecrementsTimeRemaining() {
        let presenter = FocusPresenter()
        presenter.duration = 1
        presenter.startTimer()
        let initialTime = presenter.timeRemaining

        presenter.handleTick()

        XCTAssertEqual(presenter.timeRemaining, initialTime - 1)
    }

    @MainActor
    func testHandleTickDoesNothingWhenPaused() {
        let presenter = FocusPresenter()
        presenter.duration = 1
        presenter.startTimer()
        presenter.togglePause()
        let pausedTime = presenter.timeRemaining

        presenter.handleTick()

        XCTAssertEqual(presenter.timeRemaining, pausedTime)
    }

    @MainActor
    func testHandleTickDoesNothingWhenNotRunning() {
        let presenter = FocusPresenter()
        presenter.duration = 1
        let initialTimeRemaining = presenter.timeRemaining

        presenter.handleTick()

        XCTAssertEqual(presenter.timeRemaining, initialTimeRemaining)
    }

    @MainActor
    func testHandleTickSetsCompletedWhenTimeReachesZero() {
        let presenter = FocusPresenter()
        presenter.duration = 1
        presenter.startTimer()

        // Tick down to 0
        for _ in 0..<60 {
            presenter.handleTick()
        }

        XCTAssertEqual(presenter.timeRemaining, 0)

        // One more tick should trigger completion
        presenter.handleTick()

        XCTAssertTrue(presenter.isCompleted)
        XCTAssertFalse(presenter.isRunning)
    }

    @MainActor
    func testTogglePauseFlipsPausedState() {
        let presenter = FocusPresenter()
        presenter.startTimer()

        XCTAssertFalse(presenter.isPaused)

        presenter.togglePause()
        XCTAssertTrue(presenter.isPaused)

        presenter.togglePause()
        XCTAssertFalse(presenter.isPaused)
    }

    @MainActor
    func testEndSessionResetsAllState() {
        let presenter = FocusPresenter()
        presenter.duration = 10
        presenter.startTimer()

        presenter.endSession()

        XCTAssertEqual(presenter.timeRemaining, 0)
        XCTAssertEqual(presenter.totalTime, 0)
        XCTAssertFalse(presenter.isRunning)
        XCTAssertFalse(presenter.isPaused)
        XCTAssertFalse(presenter.isCompleted)
        XCTAssertFalse(presenter.hasStarted)
    }

    @MainActor
    func testProgressCalculatesCorrectly() {
        let presenter = FocusPresenter()
        presenter.duration = 1
        presenter.startTimer()

        // Initial progress should be 1.0 (100%)
        XCTAssertEqual(presenter.progress, 1.0, accuracy: 0.001)

        // After 30 ticks (half time), progress should be 0.5
        for _ in 0..<30 {
            presenter.handleTick()
        }
        XCTAssertEqual(presenter.progress, 0.5, accuracy: 0.001)

        // When totalTime is 0, progress should be 0
        presenter.endSession()
        XCTAssertEqual(presenter.progress, 0)
    }

    @MainActor
    func testTimeStringFormatsCorrectly() {
        let presenter = FocusPresenter()
        presenter.duration = 90 // 90 minutes = 1:30:00
        presenter.startTimer()

        XCTAssertEqual(presenter.timeString, "1:30:00")

        // Tick for 30 seconds
        for _ in 0..<30 {
            presenter.handleTick()
        }
        XCTAssertEqual(presenter.timeString, "1:29:30")
    }
}
