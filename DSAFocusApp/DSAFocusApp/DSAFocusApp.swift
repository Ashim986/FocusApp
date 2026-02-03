import SwiftUI

@main
struct DSAFocusApp: App {
    @StateObject private var dataStore = DataStore()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var floatingPanel = FloatingPanelController.shared

    init() {
        // Request notification authorization on app launch
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .frame(minWidth: 800, minHeight: 600)
                .onAppear {
                    dataStore.setNotificationManager(notificationManager)
                    floatingPanel.setDataStore(dataStore)
                    // Show floating widget on app launch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        floatingPanel.show()
                    }
                    // Auto-sync with LeetCode on launch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        dataStore.syncWithLeetCode()
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandGroup(after: .appSettings) {
                Button(floatingPanel.isVisible ? "Hide Widget" : "Show Widget") {
                    floatingPanel.toggle()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView(notificationManager: notificationManager)
        }

        // Menu bar extra for quick widget toggle
        MenuBarExtra("DSA Focus", systemImage: "brain.head.profile") {
            Button(floatingPanel.isVisible ? "Hide Widget" : "Show Widget") {
                floatingPanel.toggle()
            }
            .keyboardShortcut("w", modifiers: [.command, .shift])

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                Text("Day \(SharedDataStore.currentDayNumber()) of 13")
                    .font(.headline)
                Text(SharedDataStore.todaysTopic())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)

            Divider()

            Button(dataStore.isSyncing ? "Syncing..." : "Sync with LeetCode") {
                dataStore.syncWithLeetCode()
            }
            .disabled(dataStore.isSyncing)
            .keyboardShortcut("r", modifiers: [.command])

            if !dataStore.lastSyncResult.isEmpty {
                Text(dataStore.lastSyncResult)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            Button("Quit DSA Focus") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
