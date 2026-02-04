import SwiftData
import SwiftUI

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if let container = try? ModelContainer(for: AppDataRecord.self) {
                let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
                let client = PreviewLeetCodeClient()
                let debugLogStore = DebugLogStore()
                let leetCodeSync = LeetCodeSyncInteractor(
                    appStore: appStore,
                    client: client,
                    logger: debugLogStore
                )
                let presenter = SettingsPresenter(
                    interactor: SettingsInteractor(
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        ),
                        appStore: appStore,
                        leetCodeSync: leetCodeSync
                    )
                )
                SettingsView(
                    presenter: presenter,
                    debugLogStore: debugLogStore
                )
            } else {
                Text("Preview unavailable")
            }
        }
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
