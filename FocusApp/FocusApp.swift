import AppKit
import SwiftUI

@main
@MainActor
struct FocusApp: App {
    private let container: AppContainer
    @StateObject private var contentPresenter: ContentPresenter

    init() {
        let container = AppContainer()
        self.container = container
        _contentPresenter = StateObject(wrappedValue: container.contentPresenter)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(presenter: contentPresenter, router: container.contentRouter)
                .frame(minWidth: 800, minHeight: 600)
                .task {
                    _ = await container.notificationManager.requestAuthorization()
                }
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("FocusApp", systemImage: "brain.head.profile") {
            Button("Toggle Floating Widget") {
                FloatingWidgetController.shared.toggle(presenter: container.toolbarWidgetPresenter)
            }
            Divider()
            Button("Quit FocusApp") {
                NSApp.terminate(nil)
            }
        }

        Settings {
            SettingsView(presenter: container.settingsPresenter)
        }
    }
}

@MainActor
final class FloatingWidgetController {
    static let shared = FloatingWidgetController()

    private var panel: NSPanel?

    func show(presenter: ToolbarWidgetPresenter) {
        ensurePanel(presenter: presenter)
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func toggle(presenter: ToolbarWidgetPresenter) {
        if panel?.isVisible == true {
            hide()
        } else {
            show(presenter: presenter)
        }
    }

    private func ensurePanel(presenter: ToolbarWidgetPresenter) {
        if panel != nil {
            return
        }

        let hostingController = NSHostingController(rootView: ToolbarWidgetView(presenter: presenter))
        let panel = NSPanel(contentViewController: hostingController)

        panel.setContentSize(NSSize(width: 350, height: 560))
        panel.minSize = NSSize(width: 330, height: 420)
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        panel.styleMask = [.titled, .closable, .resizable, .fullSizeContentView]
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true

        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true

        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true

        self.panel = panel
    }
}
