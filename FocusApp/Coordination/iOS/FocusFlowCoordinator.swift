import SwiftUI

/// Thin wrapper that adapts the shared `FocusCoordinator` for the iOS tab flow.
///
/// The timer logic lives in `FocusCoordinator` (shared between macOS and iOS).
/// This coordinator provides the `TabFlowRoute` interface expected by
/// `TabBarCoordinator` while delegating actual timer state to the shared instance.
@MainActor
final class FocusFlowCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: TabFlowRoute = .root

    /// The shared focus coordinator (owned by AppCoordinator).
    let focusCoordinator: FocusCoordinator

    init(focusCoordinator: FocusCoordinator) {
        self.focusCoordinator = focusCoordinator
    }

    func start() {}
}
