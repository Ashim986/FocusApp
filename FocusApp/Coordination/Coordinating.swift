import Combine
import Foundation

/// Base protocol for all coordinators in the app.
///
/// Each coordinator manages a specific navigation flow via a type-safe `Route` enum.
/// Coordinators are `@MainActor` to ensure thread-safe UI state management and
/// conform to `ObservableObject` so SwiftUI views can observe route changes.
///
/// Platform-agnostic: the same coordinator works on macOS, iOS, and iPadOS.
/// Only the views that consume the coordinator are platform-specific.
@MainActor
protocol Coordinating: AnyObject, ObservableObject {
    associatedtype Route: Hashable
    /// The currently active route for this coordinator's flow.
    var activeRoute: Route { get set }
    /// Called once when the coordinator is first set up.
    func start()
}

/// Protocol for coordinators that manage child coordinators (e.g., AppCoordinator, ContentCoordinator).
@MainActor
protocol ParentCoordinating: Coordinating {
    var childCoordinators: [any Coordinating] { get set }
    func addChild(_ coordinator: any Coordinating)
    func removeChild(_ coordinator: any Coordinating)
}

extension ParentCoordinating {
    func addChild(_ coordinator: any Coordinating) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: any Coordinating) {
        let targetID = ObjectIdentifier(coordinator)
        childCoordinators.removeAll { ObjectIdentifier($0) == targetID }
    }
}
