import SwiftUI

/// Manages the floating widget panel state.
///
/// On macOS, controls the NSPanel via `FloatingWidgetController`.
/// On iOS/iPadOS (future), would drive a WidgetKit extension or slide-over panel.
@MainActor
final class WidgetCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: WidgetRoute = .main
    @Published var isVisible: Bool = false

    private let presenter: ToolbarWidgetPresenter
    private let panelController = FloatingWidgetController.shared

    init(presenter: ToolbarWidgetPresenter) {
        self.presenter = presenter
    }

    func start() {}

    // MARK: - Panel Management

    func toggle() {
        if isVisible {
            panelController.hide()
        } else {
            panelController.show(presenter: presenter)
        }
        isVisible.toggle()
    }

    func show() {
        guard !isVisible else { return }
        panelController.show(presenter: presenter)
        isVisible = true
    }

    func hide() {
        guard isVisible else { return }
        panelController.hide()
        isVisible = false
    }

    // MARK: - Section Navigation

    func showSettings() { activeRoute = .settings }
    func showTomorrow() { activeRoute = .tomorrow }
    func showMain() { activeRoute = .main }
}
