#if os(iOS)
import FocusDesignSystem
import SwiftUI

@main
@MainActor
struct FocusAppiOS: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            DesignSystemRoot {
                iOSRootView(coordinator: coordinator)
                    .task {
                        coordinator.start()
                        _ = await coordinator.container.notificationManager.requestAuthorization()
                        await coordinator.container.leetCodeScheduler.syncNow(trigger: .hourly)
                    }
            }
        }
    }
}
#endif
