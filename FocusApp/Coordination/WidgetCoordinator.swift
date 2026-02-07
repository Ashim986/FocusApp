import SwiftUI

/// Manages the floating widget panel state.
///
/// On macOS, controls the NSPanel via `FloatingWidgetController`.
/// On iOS/iPadOS, this coordinator is not used (no floating widget).
@MainActor
final class WidgetCoordinator: Coordinating, ObservableObject {
    @Published var activeRoute: WidgetRoute = .main
    @Published var isVisible: Bool = false

    private let presenter: ToolbarWidgetPresenter
    #if os(macOS)
    private let panelController = FloatingWidgetController.shared
    #endif

    init(presenter: ToolbarWidgetPresenter) {
        self.presenter = presenter
    }

    func start() {}

    // MARK: - Panel Management

    func toggle() {
        #if os(macOS)
        if isVisible {
            panelController.hide()
        } else {
            panelController.show(presenter: presenter)
        }
        #endif
        isVisible.toggle()
    }

    func show() {
        guard !isVisible else { return }
        #if os(macOS)
        panelController.show(presenter: presenter)
        #endif
        isVisible = true
    }

    func hide() {
        guard isVisible else { return }
        #if os(macOS)
        panelController.hide()
        #endif
        isVisible = false
    }

    // MARK: - Section Navigation

    func showSettings() { activeRoute = .settings }
    func showTomorrow() { activeRoute = .tomorrow }
    func showMain() { activeRoute = .main }
}
