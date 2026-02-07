@testable import FocusApp
import Foundation

@MainActor
struct CodingEnvironmentHarness {
    let presenter: CodingEnvironmentPresenter
    let store: AppStateStore
    let client: StubLeetCodeClient
    let executor: StubCodeExecutor
}

@MainActor
func makeCodingEnvironmentHarness(
    client: StubLeetCodeClient = StubLeetCodeClient(),
    executor: StubCodeExecutor = StubCodeExecutor(),
    solutionStore: SolutionProviding = StubSolutionStore(),
    date: Date = makeDate(year: 2026, month: 2, day: 3)
) -> CodingEnvironmentHarness {
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: date),
        dateProvider: FixedDateProvider(date: date)
    )

    let interactor = CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: client,
        executionService: executor,
        solutionStore: solutionStore
    )

    let presenter = CodingEnvironmentPresenter(interactor: interactor)

    return CodingEnvironmentHarness(
        presenter: presenter,
        store: store,
        client: client,
        executor: executor
    )
}
