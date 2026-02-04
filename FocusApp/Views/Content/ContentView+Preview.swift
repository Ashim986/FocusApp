import SwiftUI

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let storage = FileAppStorage()
        let appStore = AppStateStore(storage: storage)
        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: URLSessionRequestExecutor()
        )
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
                        )
                    )
                )
                return PlanView(presenter: planPresenter)
            },
            makeToday: { focusBinding, codeBinding in
                let todayPresenter = TodayPresenter(
                    interactor: TodayInteractor(
                        appStore: appStore,
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        )
                    )
                )
                return TodayView(
                    presenter: todayPresenter,
                    showFocusMode: focusBinding,
                    showCodeEnvironment: codeBinding
                )
            },
            makeStats: {
                let statsPresenter = StatsPresenter(interactor: StatsInteractor(appStore: appStore))
                return StatsView(presenter: statsPresenter)
            },
            makeFocus: { binding in
                let focusPresenter = FocusPresenter()
                return FocusOverlay(presenter: focusPresenter, isPresented: binding)
            },
            makeCoding: { binding in
                CodingEnvironmentView(presenter: codingPresenter, onBack: { binding.wrappedValue = false })
            }
        )

        return ContentView(presenter: presenter, router: router)
            .frame(width: 800, height: 600)
    }
}
#endif
