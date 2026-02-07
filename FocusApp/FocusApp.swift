import AppKit
import FocusDesignSystem
import SwiftUI

@main
@MainActor
struct FocusApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            DesignSystemRoot {
                ContentView(
                    presenter: coordinator.container.contentPresenter,
                    coordinator: coordinator.contentCoordinator
                )
                .frame(minWidth: 800, minHeight: 600)
                .task {
                    coordinator.start()
                    _ = await coordinator.container.notificationManager.requestAuthorization()
                    await coordinator.container.leetCodeScheduler.syncNow(trigger: .hourly)
                }
            }
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("FocusApp", systemImage: "brain.head.profile") {
            Button("Toggle Floating Widget") {
                coordinator.toggleWidget()
            }
            Divider()
            Button("Quit FocusApp") {
                NSApp.terminate(nil)
            }
        }

        Settings {
            DesignSystemRoot {
                SettingsView(
                    presenter: coordinator.container.settingsPresenter,
                    debugLogStore: coordinator.container.debugLogStore
                )
            }
        }
    }
}

private struct DesignSystemRoot<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        DSThemeProvider(theme: colorScheme == .dark ? .dark : .light) {
            content
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
