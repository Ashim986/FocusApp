import SwiftData
import SwiftUI

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        guard let container = try? ModelContainer(
            for: AppDataRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) else {
            return Text("Preview unavailable")
        }
        let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
        let client = PreviewLeetCodeClient()
        let syncInteractor = LeetCodeSyncInteractor(appStore: appStore, client: client)
        let codeExecutionService = CodeExecutionService()
        let codingPresenter = CodingEnvironmentPresenter(
            interactor: CodingEnvironmentInteractor(
                appStore: appStore,
                leetCodeClient: client,
                executionService: codeExecutionService
            )
        )
        let presenter = ContentPresenter(interactor: ContentInteractor(appStore: appStore))
        let router = ContentRouter(
            makePlan: {
                let planPresenter = PlanPresenter(
                    interactor: PlanInteractor(
                        appStore: appStore,
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        ),
                        leetCodeSync: syncInteractor
                    )
                )
                return PlanView(presenter: planPresenter)
            },
            makeToday: { codeBinding in
                let todayPresenter = TodayPresenter(
                    interactor: TodayInteractor(
                        appStore: appStore,
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        ),
                        leetCodeSync: syncInteractor
                    )
                )
                return TodayView(
                    presenter: todayPresenter,
                    showCodeEnvironment: codeBinding
                )
            },
            makeStats: {
                let statsPresenter = StatsPresenter(interactor: StatsInteractor(appStore: appStore))
                return StatsView(presenter: statsPresenter)
            },
            makeCoding: { binding in
                CodingEnvironmentView(presenter: codingPresenter, onBack: { binding.wrappedValue = false })
            }
        )

        return ContentView(presenter: presenter, router: router)
            .frame(width: 800, height: 600)
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
