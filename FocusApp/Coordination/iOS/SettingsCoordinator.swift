import SwiftUI

/// Manages settings sheet presentation on iOS.
///
/// Replaces the `@State showSettings` boolean in `RootViewiOS` with
/// coordinator-driven state. Provides an `isPresentedBinding` for
/// SwiftUI `.sheet(isPresented:)` integration.
@MainActor
final class SettingsCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: SettingsRoute = .closed

    var isPresented: Bool {
        activeRoute == .presented
    }

    /// Binding for `.sheet(isPresented:)` that syncs with `activeRoute`.
    var isPresentedBinding: Binding<Bool> {
        Binding(
            get: { self.isPresented },
            set: { newValue in
                self.activeRoute = newValue ? .presented : .closed
            }
        )
    }

    init() {}

    func start() {}

    func present() {
        activeRoute = .presented
    }

    func dismiss() {
        activeRoute = .closed
    }
}
