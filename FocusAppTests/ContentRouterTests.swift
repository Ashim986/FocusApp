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
        let interactor = PlanInteractor(appStore: store, notificationManager: notificationManager)
        let presenter = PlanPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { PlanView(presenter: presenter) },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { fatalError("not under test") },
            makeFocus: { _ in fatalError("not under test") },
            makeCoding: { _ in fatalError("not under test") }
        )

        let view = router.makePlan()

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
        let interactor = TodayInteractor(appStore: store, notificationManager: notificationManager)
        let presenter = TodayPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { fatalError("not under test") },
            makeToday: { showFocus, showCode in
                TodayView(presenter: presenter, showFocusMode: showFocus, showCodeEnvironment: showCode)
            },
            makeStats: { fatalError("not under test") },
            makeFocus: { _ in fatalError("not under test") },
            makeCoding: { _ in fatalError("not under test") }
        )

        var showFocus = false
        var showCode = false
        let focusBinding = Binding(get: { showFocus }, set: { showFocus = $0 })
        let codeBinding = Binding(get: { showCode }, set: { showCode = $0 })

        let view = router.makeToday(focusBinding, codeBinding)

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
            makePlan: { fatalError("not under test") },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { StatsView(presenter: presenter) },
            makeFocus: { _ in fatalError("not under test") },
            makeCoding: { _ in fatalError("not under test") }
        )

        let view = router.makeStats()

        XCTAssertNotNil(view)
    }

    @MainActor
    func testMakeFocusReturnsFocusOverlay() {
        let presenter = FocusPresenter()

        let router = ContentRouter(
            makePlan: { fatalError("not under test") },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { fatalError("not under test") },
            makeFocus: { isPresented in FocusOverlay(presenter: presenter, isPresented: isPresented) },
            makeCoding: { _ in fatalError("not under test") }
        )

        var isPresented = false
        let binding = Binding(get: { isPresented }, set: { isPresented = $0 })

        let view = router.makeFocus(binding)

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
        let interactor = CodingEnvironmentInteractor(
            appStore: store,
            leetCodeClient: client,
            executionService: executor
        )
        let presenter = CodingEnvironmentPresenter(interactor: interactor)

        let router = ContentRouter(
            makePlan: { fatalError("not under test") },
            makeToday: { _, _ in fatalError("not under test") },
            makeStats: { fatalError("not under test") },
            makeFocus: { _ in fatalError("not under test") },
            makeCoding: { isPresented in CodingEnvironmentView(presenter: presenter, isPresented: isPresented) }
        )

        var isPresented = false
        let binding = Binding(get: { isPresented }, set: { isPresented = $0 })

        let view = router.makeCoding(binding)

        XCTAssertNotNil(view)
    }
}
