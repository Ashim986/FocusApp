import SwiftUI

/// Manages navigation within the Today tab on iOS.
///
/// Currently the Today tab is a single screen. This coordinator
/// exists for extensibility (e.g., push to problem detail in the future).
@MainActor
final class TodayFlowCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: TabFlowRoute = .root

    let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    func start() {}

    func popToRoot() {
        activeRoute = .root
    }
}
