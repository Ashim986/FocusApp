import AppKit
import SwiftUI

class FloatingPanelController: NSObject, ObservableObject {
    static let shared = FloatingPanelController()

    @Published var isVisible: Bool = false

    private var panel: NSPanel?
    private var dataStore: DataStore?

    private override init() {
        super.init()
    }

    func setDataStore(_ store: DataStore) {
        self.dataStore = store
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        guard panel == nil, let dataStore = dataStore else {
            panel?.makeKeyAndOrderFront(nil)
            isVisible = true
            return
        }

        let contentView = FloatingWidgetView(onClose: { [weak self] in
            self?.hide()
        })
        .environmentObject(dataStore)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 300, height: 420)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 420),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.contentView = hostingView
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true

        // Position at top-left corner with some padding
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.minX + 20
            let y = screenFrame.maxY - panel.frame.height - 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)

        self.panel = panel
        self.isVisible = true
    }

    func hide() {
        panel?.close()
        panel = nil
        isVisible = false
    }
}
