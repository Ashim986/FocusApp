import SwiftData
import SwiftUI

#if DEBUG
struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if let container = try? ModelContainer(for: AppDataRecord.self) {
                let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
                let client = PreviewLeetCodeClient()
                let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
                let presenter = TodayPresenter(
                    interactor: TodayInteractor(
                        appStore: appStore,
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        ),
                        leetCodeSync: leetCodeSync
                    )
                )
                TodayView(
                    presenter: presenter,
                    onSelectProblem: { _, _, _ in }
                )
                    .frame(width: 600, height: 800)
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
