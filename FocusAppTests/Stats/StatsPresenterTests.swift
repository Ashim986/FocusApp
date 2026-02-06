@testable import FocusApp
import XCTest

final class StatsPresenterTests: XCTestCase {
    @MainActor
    func testInitialViewModelCalculatesCorrectly() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)
        let presenter = StatsPresenter(interactor: interactor)

        let expectedTotal = dsaPlan.reduce(0) { $0 + $1.problems.count }

        XCTAssertEqual(presenter.viewModel.totalProblems, expectedTotal)
        XCTAssertEqual(presenter.viewModel.solvedProblems, 0)
        XCTAssertEqual(presenter.viewModel.totalTopics, dsaPlan.count)
        XCTAssertEqual(presenter.viewModel.completedTopics, 0)
    }

    @MainActor
    func testViewModelUpdatesWhenDataChanges() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)
        let presenter = StatsPresenter(interactor: interactor)

        XCTAssertEqual(presenter.viewModel.solvedProblems, 0)

        // Solve some problems
        store.toggleProblem(day: 1, problemIndex: 0)
        store.toggleProblem(day: 1, problemIndex: 1)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.viewModel.solvedProblems, 2)
    }

    @MainActor
    func testTopicBreakdownMatchesPlan() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)
        let presenter = StatsPresenter(interactor: interactor)

        XCTAssertEqual(presenter.viewModel.topicBreakdown.count, dsaPlan.count)
        XCTAssertEqual(presenter.viewModel.topicBreakdown.first?.topic, "Priority Sprint I")
        XCTAssertEqual(presenter.viewModel.topicBreakdown.last?.topic, "1-D DP (cont.) + 2-D DP Intro")
    }

    @MainActor
    func testCompletedTopicsCountMatchesData() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = StatsInteractor(appStore: store)
        let presenter = StatsPresenter(interactor: interactor)

        XCTAssertEqual(presenter.viewModel.completedTopics, 0)

        // Complete all problems in day 1 (sprint = 11 problems)
        for i in 0..<11 {
            store.toggleProblem(day: 1, problemIndex: i)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.viewModel.completedTopics, 1)
        XCTAssertTrue(presenter.viewModel.topicBreakdown[0].isComplete)
    }
}
