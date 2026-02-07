import SwiftUI

/// Manages the focus timer flow, decoupled from CodingEnvironmentView.
///
/// Previously the timer was embedded as a `@StateObject` in `CodingEnvironmentView`,
/// tightly coupling it to the code editor. This coordinator makes the timer
/// reusable across any view (standalone Focus tab, coding environment, etc.).
@MainActor
final class FocusCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: FocusRoute = .idle
    let presenter: FocusPresenter

    init() {
        self.presenter = FocusPresenter()
    }

    func start() {}

    // MARK: - Timer Actions

    func startFocusSession(minutes: Int) {
        presenter.duration = minutes
        presenter.startTimer()
        activeRoute = .running
    }

    func pause() {
        presenter.togglePause()
        activeRoute = presenter.isPaused ? .paused : .running
    }

    func resume() {
        presenter.togglePause()
        activeRoute = .running
    }

    func endSession() {
        presenter.endSession()
        activeRoute = .idle
    }

    func resetSession() {
        presenter.resetSession()
        activeRoute = .idle
    }

    /// Call from a timer tick to update state. Transitions to `.completed` when done.
    func handleTick() {
        presenter.handleTick()
        if presenter.isCompleted {
            activeRoute = .completed
        }
    }

    /// Whether a focus session is active (running or paused).
    var isSessionActive: Bool {
        activeRoute == .running || activeRoute == .paused
    }
}
