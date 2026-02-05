@testable import FocusApp
import SwiftUI
import XCTest

final class ContentRouterTests: XCTestCase {
    @MainActor
    func testMakePlanReturnsPlanView() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = PlanInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = PlanPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { onSelectProblem in
                PlanView(presenter: presenter, onSelectProblem: onSelectProblem)
            },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { fatalError("not under test") },
            makeCoding: { _ in fatalError("not under test") },
            selectProblem: { _, _, _ in }
        )

        let view = router.makePlan { _, _, _ in }

        XCTAssertNotNil(view)
    }

    @MainActor
    func testMakeTodayReturnsTodayView() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let notificationManager = FakeNotificationManager()
        let interactor = TodayInteractor(
            appStore: store,
            notificationManager: notificationManager,
            leetCodeSync: makeLeetCodeSync(store: store)
        )
        let presenter = TodayPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { _ in fatalError("not under test") },
            makeToday: { showCode, onSelectProblem in
                TodayView(presenter: presenter, showCodeEnvironment: showCode, onSelectProblem: onSelectProblem)
            },
            makeStats: { fatalError("not under test") },
            makeCoding: { _ in fatalError("not under test") },
            selectProblem: { _, _, _ in }
        )

        var showCode = false
        let codeBinding = Binding(get: { showCode }, set: { showCode = $0 })

        let view = router.makeToday(codeBinding) { _, _, _ in }

        XCTAssertNotNil(view)
    }

    @MainActor
    func testMakeStatsReturnsStatsView() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)
        let presenter = StatsPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { _ in fatalError("not under test") },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { StatsView(presenter: presenter) },
            makeCoding: { _ in fatalError("not under test") },
            selectProblem: { _, _, _ in }
        )

        let view = router.makeStats()

        XCTAssertNotNil(view)
    }

    @MainActor
    func testMakeCodingReturnsCodingEnvironmentView() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        let executor = FakeCodeExecutor()
        let solutionStore = FakeSolutionStore()
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor,
            solutionStore: solutionStore
        )
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { _ in fatalError("not under test") },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { fatalError("not under test") },
            makeCoding: { isPresented in
                CodingEnvironmentView(
                    presenter: presenter,
                    debugLogStore: DebugLogStore(),
                    onBack: { isPresented.wrappedValue = false }
                )
            },
            selectProblem: { _, _, _ in }
        )

        var isPresented = false
        let binding = Binding(get: { isPresented }, set: { isPresented = $0 })

        let view = router.makeCoding(binding)

        XCTAssertNotNil(view)
    }
}

@MainActor
private func makeLeetCodeSync(store: AppStateStore) -> LeetCodeSyncInteractor {
    LeetCodeSyncInteractor(appStore: store, client: FakeLeetCodeClient())
}
