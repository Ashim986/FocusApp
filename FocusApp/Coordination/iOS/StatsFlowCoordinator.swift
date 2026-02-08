import SwiftUI

/// Manages navigation within the Stats tab on iOS.
///
/// Currently the Stats tab is a single screen. This coordinator
/// exists for extensibility.
@MainActor
final class StatsFlowCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: TabFlowRoute = .root

    init() {}

    func start() {}

    func popToRoot() {
        activeRoute = .root
    }
}
