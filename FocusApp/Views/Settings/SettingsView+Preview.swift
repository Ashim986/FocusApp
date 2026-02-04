import SwiftData
import SwiftUI

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        guard let container = try? ModelContainer(
            for: AppDataRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) else {
            return Text("Preview unavailable")
        }
        let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
        let client = PreviewLeetCodeClient()
        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
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
        return SettingsView(presenter: presenter)
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
