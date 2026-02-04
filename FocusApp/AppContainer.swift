import Foundation
import SwiftUI
import SwiftData

@MainActor
final class AppContainer {
    let modelContainer: ModelContainer
    let appStore: AppStateStore
    let notificationManager: NotificationManager
    let leetCodeSync: LeetCodeSyncInteractor
    let leetCodeClient: LeetCodeClientProtocol
    let leetCodeScheduler: LeetCodeSyncScheduler
    let codeExecutionService: CodeExecutionService

    let contentPresenter: ContentPresenter
    let planPresenter: PlanPresenter
    let todayPresenter: TodayPresenter
    let statsPresenter: StatsPresenter
    let settingsPresenter: SettingsPresenter
    let focusPresenter: FocusPresenter
    let toolbarWidgetPresenter: ToolbarWidgetPresenter
    let codingEnvironmentPresenter: CodingEnvironmentPresenter

    lazy var contentRouter: ContentRouter = {
        ContentRouter(
            makePlan: { [unowned self] in
                PlanView(presenter: planPresenter)
            },
            makeToday: { [unowned self] focusBinding, codeBinding in
                TodayView(
                    presenter: todayPresenter,
                    showFocusMode: focusBinding,
                    showCodeEnvironment: codeBinding
                )
            },
            makeStats: { [unowned self] in
                StatsView(presenter: statsPresenter)
            },
            makeFocus: { [unowned self] binding in
                FocusOverlay(
                    presenter: focusPresenter,
                    isPresented: binding
                )
            },
            makeCoding: { [unowned self] binding in
                CodingEnvironmentView(
                    presenter: codingEnvironmentPresenter,
                    onBack: { binding.wrappedValue = false }
                )
            }
        )
    }()

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: AppDataRecord.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
        self.modelContainer = container

        let storage = SwiftDataAppStorage(container: container)
        let appStore = AppStateStore(storage: storage)
        self.appStore = appStore

        let notificationManager = NotificationManager(
            scheduler: SystemNotificationScheduler(),
            store: UserDefaultsNotificationSettingsStore()
        )
        self.notificationManager = notificationManager

        let executor = URLSessionRequestExecutor()
        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: executor
        )
        self.leetCodeClient = client

        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
        self.leetCodeSync = leetCodeSync
        let leetCodeScheduler = LeetCodeSyncScheduler(appStore: appStore, syncer: leetCodeSync)
        leetCodeScheduler.start()
        self.leetCodeScheduler = leetCodeScheduler

        let codeExecutionService = CodeExecutionService()
        self.codeExecutionService = codeExecutionService

        self.contentPresenter = ContentPresenter(
            interactor: ContentInteractor(appStore: appStore)
        )
        self.planPresenter = PlanPresenter(
            interactor: PlanInteractor(
                appStore: appStore,
                notificationManager: notificationManager,
                leetCodeSync: leetCodeSync
            )
        )
        self.todayPresenter = TodayPresenter(
            interactor: TodayInteractor(
                appStore: appStore,
                notificationManager: notificationManager,
                leetCodeSync: leetCodeSync
            )
        )
        self.statsPresenter = StatsPresenter(
            interactor: StatsInteractor(appStore: appStore)
        )
        self.settingsPresenter = SettingsPresenter(
            interactor: SettingsInteractor(
                notificationManager: notificationManager,
                appStore: appStore,
                leetCodeSync: leetCodeSync
            )
        )
        self.focusPresenter = FocusPresenter()
        self.toolbarWidgetPresenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        self.codingEnvironmentPresenter = CodingEnvironmentPresenter(
            interactor: CodingEnvironmentInteractor(
                appStore: appStore,
                leetCodeClient: client,
                executionService: codeExecutionService
            )
        )
    }
}
