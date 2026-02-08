import Foundation
import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    private struct Built {
        let notificationManager: NotificationManager
        let debugLogStore: DebugLogStore
        let leetCodeClient: LeetCodeClientProtocol
        let leetCodeSync: LeetCodeSyncInteractor
        let leetCodeScheduler: LeetCodeSyncScheduler
        let codeExecutionService: CodeExecuting
        let solutionStore: SolutionProviding

        let contentPresenter: ContentPresenter
        let planPresenter: PlanPresenter
        let todayPresenter: TodayPresenter
        let statsPresenter: StatsPresenter
        let settingsPresenter: SettingsPresenter
        let toolbarWidgetPresenter: ToolbarWidgetPresenter
        let codingEnvironmentPresenter: CodingEnvironmentPresenter
    }

    let modelContainer: ModelContainer
    let appStore: AppStateStore
    let notificationManager: NotificationManager
    let leetCodeSync: LeetCodeSyncInteractor
    let leetCodeClient: LeetCodeClientProtocol
    let leetCodeScheduler: LeetCodeSyncScheduler
    let codeExecutionService: CodeExecuting
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
        self.modelContainer = Self.makeModelContainer(inMemory: true)
        self.appStore = appStore

        let built = Self.build(appStore: appStore, shouldStartScheduler: false)
        (
            self.notificationManager,
            self.debugLogStore,
            self.leetCodeClient,
            self.leetCodeSync,
            self.leetCodeScheduler,
            self.codeExecutionService,
            self.solutionStore,
            self.contentPresenter,
            self.planPresenter,
            self.todayPresenter,
            self.statsPresenter,
            self.settingsPresenter,
            self.toolbarWidgetPresenter,
            self.codingEnvironmentPresenter
        ) = (
            built.notificationManager,
            built.debugLogStore,
            built.leetCodeClient,
            built.leetCodeSync,
            built.leetCodeScheduler,
            built.codeExecutionService,
            built.solutionStore,
            built.contentPresenter,
            built.planPresenter,
            built.todayPresenter,
            built.statsPresenter,
            built.settingsPresenter,
            built.toolbarWidgetPresenter,
            built.codingEnvironmentPresenter
        )
    }

    init() {
        let modelContainer = Self.makeModelContainer(inMemory: false)
        self.modelContainer = modelContainer

        let storage = SwiftDataAppStorage(container: modelContainer)
        let appStore = AppStateStore(storage: storage)
        self.appStore = appStore

        let built = Self.build(appStore: appStore, shouldStartScheduler: true)
        (
            self.notificationManager,
            self.debugLogStore,
            self.leetCodeClient,
            self.leetCodeSync,
            self.leetCodeScheduler,
            self.codeExecutionService,
            self.solutionStore,
            self.contentPresenter,
            self.planPresenter,
            self.todayPresenter,
            self.statsPresenter,
            self.settingsPresenter,
            self.toolbarWidgetPresenter,
            self.codingEnvironmentPresenter
        ) = (
            built.notificationManager,
            built.debugLogStore,
            built.leetCodeClient,
            built.leetCodeSync,
            built.leetCodeScheduler,
            built.codeExecutionService,
            built.solutionStore,
            built.contentPresenter,
            built.planPresenter,
            built.todayPresenter,
            built.statsPresenter,
            built.settingsPresenter,
            built.toolbarWidgetPresenter,
            built.codingEnvironmentPresenter
        )
    }

    private static func makeModelContainer(inMemory: Bool) -> ModelContainer {
        do {
            if inMemory {
                return try ModelContainer(
                    for: AppDataRecord.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
            }
            return try ModelContainer(for: AppDataRecord.self)
        } catch {
            let kind = inMemory ? "in-memory SwiftData" : "SwiftData"
            fatalError("Failed to create \(kind) container: \(error)")
        }
    }

    private static func build(appStore: AppStateStore, shouldStartScheduler: Bool) -> Built {
        let notificationManager = NotificationManager(
            scheduler: SystemNotificationScheduler(),
            store: UserDefaultsNotificationSettingsStore()
        )

        let debugLogStore = DebugLogStore()
        let executor = URLSessionRequestExecutor(logger: debugLogStore)

        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: executor
        )
        let submissionService = LeetCodeSubmissionService(executor: executor)
        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client, logger: debugLogStore)
        let leetCodeScheduler = LeetCodeSyncScheduler(appStore: appStore, syncer: leetCodeSync)
        if shouldStartScheduler {
            leetCodeScheduler.start()
        }

        #if os(macOS)
        let codeExecutionService = CodeExecutionService(logger: debugLogStore)
        #else
        let codeExecutionService = LeetCodeExecutionService(executor: executor, logger: debugLogStore)
        #endif

        let topicStore = TopicSolutionStore()
        let solutionStore = OnDemandSolutionProvider(bundledStore: topicStore)

        let contentPresenter = ContentPresenter(interactor: ContentInteractor(appStore: appStore))
        let planPresenter = PlanPresenter(
            interactor: PlanInteractor(
                appStore: appStore,
                notificationManager: notificationManager,
                leetCodeSync: leetCodeSync
            )
        )
        let todayPresenter = TodayPresenter(
            interactor: TodayInteractor(
                appStore: appStore,
                notificationManager: notificationManager,
                leetCodeSync: leetCodeSync
            )
        )
        let statsPresenter = StatsPresenter(interactor: StatsInteractor(appStore: appStore))
        let settingsPresenter = SettingsPresenter(
            interactor: SettingsInteractor(
                notificationManager: notificationManager,
                appStore: appStore,
                leetCodeSync: leetCodeSync
            )
        )
        let toolbarWidgetPresenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        let codingEnvironmentPresenter = CodingEnvironmentPresenter(
            interactor: CodingEnvironmentInteractor(
                appStore: appStore,
                leetCodeClient: client,
                executionService: codeExecutionService,
                solutionStore: solutionStore,
                submissionService: submissionService
            ),
            logger: debugLogStore
        )

        return Built(
            notificationManager: notificationManager,
            debugLogStore: debugLogStore,
            leetCodeClient: client,
            leetCodeSync: leetCodeSync,
            leetCodeScheduler: leetCodeScheduler,
            codeExecutionService: codeExecutionService,
            solutionStore: solutionStore,
            contentPresenter: contentPresenter,
            planPresenter: planPresenter,
            todayPresenter: todayPresenter,
            statsPresenter: statsPresenter,
            settingsPresenter: settingsPresenter,
            toolbarWidgetPresenter: toolbarWidgetPresenter,
            codingEnvironmentPresenter: codingEnvironmentPresenter
        )
    }
}
