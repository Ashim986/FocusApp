import SwiftUI

/// Manages navigation within the Plan tab on iOS.
///
/// Currently the Plan tab is a single screen. This coordinator
/// exists for extensibility (e.g., push to day detail or problem detail).
@MainActor
final class PlanFlowCoordinator: Coordinating, ObservableObject {
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
