import Foundation
import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    let modelContainer: ModelContainer
    let appStore: AppStateStore
    let notificationManager: NotificationManager
    let leetCodeSync: LeetCodeSyncInteractor
    let leetCodeClient: LeetCodeClientProtocol
    let leetCodeScheduler: LeetCodeSyncScheduler
    let codeExecutionService: CodeExecutionService
    let solutionStore: SolutionProviding
    let debugLogStore: DebugLogStore

    let contentPresenter: ContentPresenter
    let planPresenter: PlanPresenter
    let todayPresenter: TodayPresenter
    let statsPresenter: StatsPresenter
    let settingsPresenter: SettingsPresenter
    let toolbarWidgetPresenter: ToolbarWidgetPresenter
    let codingEnvironmentPresenter: CodingEnvironmentPresenter

    /// Test-friendly initializer that accepts a pre-configured AppStateStore.
    /// Skips SwiftData and uses in-memory storage for fast, isolated tests.
    init(appStore: AppStateStore) {
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: AppDataRecord.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Failed to create in-memory SwiftData container: \(error)")
        }
        self.modelContainer = container
        self.appStore = appStore

        let notificationManager = NotificationManager(
            scheduler: SystemNotificationScheduler(),
            store: UserDefaultsNotificationSettingsStore()
        )
        self.notificationManager = notificationManager

        let debugLogStore = DebugLogStore()
        self.debugLogStore = debugLogStore

        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: URLSessionRequestExecutor(logger: debugLogStore)
        )
        self.leetCodeClient = client
        let submissionService = LeetCodeSubmissionService(
            executor: URLSessionRequestExecutor(logger: debugLogStore)
        )

        let leetCodeSync = LeetCodeSyncInteractor(
            appStore: appStore,
            client: client,
            logger: debugLogStore
        )
        self.leetCodeSync = leetCodeSync
        self.leetCodeScheduler = LeetCodeSyncScheduler(appStore: appStore, syncer: leetCodeSync)

        let codeExecutionService = CodeExecutionService(logger: debugLogStore)
        self.codeExecutionService = codeExecutionService

        let topicStore = TopicSolutionStore()
        let solutionStore = OnDemandSolutionProvider(bundledStore: topicStore)
        self.solutionStore = solutionStore

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
        self.toolbarWidgetPresenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        self.codingEnvironmentPresenter = CodingEnvironmentPresenter(
            interactor: CodingEnvironmentInteractor(
                appStore: appStore,
                leetCodeClient: client,
                executionService: codeExecutionService,
                solutionStore: solutionStore,
                submissionService: submissionService
            ),
            logger: debugLogStore
        )
    }

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

        let debugLogStore = DebugLogStore()
        self.debugLogStore = debugLogStore

        let executor = URLSessionRequestExecutor(logger: debugLogStore)
        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: executor
        )
        self.leetCodeClient = client
        let submissionService = LeetCodeSubmissionService(executor: executor)

        let leetCodeSync = LeetCodeSyncInteractor(
            appStore: appStore,
            client: client,
            logger: debugLogStore
        )
        self.leetCodeSync = leetCodeSync
        let leetCodeScheduler = LeetCodeSyncScheduler(appStore: appStore, syncer: leetCodeSync)
        leetCodeScheduler.start()
        self.leetCodeScheduler = leetCodeScheduler

        let codeExecutionService = CodeExecutionService(logger: debugLogStore)
        self.codeExecutionService = codeExecutionService

        let topicStore = TopicSolutionStore()
        let solutionStore = OnDemandSolutionProvider(bundledStore: topicStore)
        self.solutionStore = solutionStore

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
        self.toolbarWidgetPresenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        self.codingEnvironmentPresenter = CodingEnvironmentPresenter(
            interactor: CodingEnvironmentInteractor(
                appStore: appStore,
                leetCodeClient: client,
                executionService: codeExecutionService,
                solutionStore: solutionStore,
                submissionService: submissionService
            ),
            logger: debugLogStore
        )
    }
}
