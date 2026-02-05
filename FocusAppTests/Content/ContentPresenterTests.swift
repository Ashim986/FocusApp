@testable import FocusApp
import XCTest

final class ContentPresenterTests: XCTestCase {
    @MainActor
    func testInitialStateCalculatesTotalProblems() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)
        let presenter = ContentPresenter(interactor: interactor)

        let expectedTotal = dsaPlan.reduce(0) { $0 + $1.problems.count }
        XCTAssertEqual(presenter.totalProblems, expectedTotal)
    }

    @MainActor
    func testBindUpdatesSolvedProblemsFromData() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)
        let presenter = ContentPresenter(interactor: interactor)

        XCTAssertEqual(presenter.solvedProblems, 0)

        // Mark some problems as solved
        store.toggleProblem(day: 1, problemIndex: 0)
        store.toggleProblem(day: 1, problemIndex: 1)

        // Allow the Combine binding to propagate
        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertEqual(presenter.solvedProblems, 2)
    }

    @MainActor
    func testProgressPercentCalculatesCorrectly() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)
        let presenter = ContentPresenter(interactor: interactor)

        XCTAssertEqual(presenter.progressPercent, 0)

        // Mark all problems in day 1 as solved (5 problems)
        for i in 0..<5 {
            store.toggleProblem(day: 1, problemIndex: i)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        let expectedPercent = Double(5) / Double(presenter.totalProblems)
        XCTAssertEqual(presenter.progressPercent, expectedPercent, accuracy: 0.001)
    }

    @MainActor
    func testSelectedTabDefaultsToToday() {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let store = AppStateStore(
            storage: InMemoryAppStorage(),
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let interactor = ContentInteractor(appStore: store)
        let presenter = ContentPresenter(interactor: interactor)

        XCTAssertEqual(presenter.selectedTab, .today)
    }
}
