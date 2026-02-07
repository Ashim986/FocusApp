import SwiftUI

/// Root coordinator for the entire app.
///
/// Owns the `AppContainer` (DI) and manages child coordinators for each major flow:
/// - `ContentCoordinator` for the main window (tabs + coding environment)
/// - `WidgetCoordinator` for the floating widget panel (macOS only)
/// - `FocusCoordinator` for the focus timer flow
@MainActor
final class AppCoordinator: ParentCoordinating, ObservableObject {
    @Published var activeRoute: AppRoute = .main
    var childCoordinators: [any Coordinating] = []

    let container: AppContainer
    let contentCoordinator: ContentCoordinator
    let focusCoordinator: FocusCoordinator
    #if os(macOS)
    let widgetCoordinator: WidgetCoordinator
    #endif

    init() {
        let container = AppContainer()
        self.container = container
        self.contentCoordinator = ContentCoordinator(container: container)
        self.focusCoordinator = FocusCoordinator()
        #if os(macOS)
        self.widgetCoordinator = WidgetCoordinator(presenter: container.toolbarWidgetPresenter)
        addChild(widgetCoordinator)
        #endif
        addChild(contentCoordinator)
        addChild(focusCoordinator)
    }

    func start() {
        contentCoordinator.start()
    }

    // MARK: - Global Navigation Actions

    #if os(macOS)
    func toggleWidget() {
        widgetCoordinator.toggle()
    }
    #endif
}
