import SwiftUI

/// Root coordinator for the entire app.
///
/// Owns the `AppContainer` (DI) and manages child coordinators for each major flow:
/// - `ContentCoordinator` for the main window (tabs + coding environment)
/// - `WidgetCoordinator` for the floating widget panel
@MainActor
final class AppCoordinator: ParentCoordinating, ObservableObject {
    @Published var activeRoute: AppRoute = .main
    var childCoordinators: [any Coordinating] = []

    let container: AppContainer
    let contentCoordinator: ContentCoordinator
    let widgetCoordinator: WidgetCoordinator

    init() {
        let container = AppContainer()
        self.container = container
        self.contentCoordinator = ContentCoordinator(container: container)
        self.widgetCoordinator = WidgetCoordinator(presenter: container.toolbarWidgetPresenter)
        addChild(contentCoordinator)
        addChild(widgetCoordinator)
    }

    func start() {
        contentCoordinator.start()
    }

    // MARK: - Global Navigation Actions

    func toggleWidget() {
        widgetCoordinator.toggle()
    }
}
