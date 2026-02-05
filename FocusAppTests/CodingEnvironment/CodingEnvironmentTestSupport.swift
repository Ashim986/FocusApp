@testable import FocusApp
import XCTest

@MainActor
func makeCodingPresenter() -> CodingEnvironmentPresenter {
    CodingEnvironmentPresenter(interactor: makeCodingInteractor())
}

@MainActor
func makeCodingInteractor() -> CodingEnvironmentInteractor {
    let start = makeDate(year: 2026, month: 2, day: 3)
    let store = AppStateStore(
        storage: InMemoryAppStorage(),
        calendar: PlanCalendar(startDate: start),
        dateProvider: FixedDateProvider(date: start)
    )
    return CodingEnvironmentInteractor(
        appStore: store,
        leetCodeClient: FakeLeetCodeClient(),
        executionService: FakeCodeExecutor(),
        solutionStore: FakeSolutionStore()
    )
}

func functionMetaJSON(name: String, params: [(String, String)], returnType: String) -> String {
    let paramsJSON = params.map { "{\"name\":\"\($0.0)\",\"type\":\"\($0.1)\"}" }.joined(separator: ",")
    return "{\"name\":\"\(name)\",\"params\":[\(paramsJSON)],\"return\":{\"type\":\"\(returnType)\"}}"
}
