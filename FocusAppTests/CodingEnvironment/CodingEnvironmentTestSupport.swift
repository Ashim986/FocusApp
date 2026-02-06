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

func problemWithSlug(
    _ slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> Problem {
    for day in dsaPlan {
        for problem in day.problems {
            if LeetCodeSlugExtractor.extractSlug(from: problem.url) == slug {
                return problem
            }
        }
    }
    XCTFail("Missing problem for slug \(slug)", file: file, line: line)
    return dsaPlan.first?.problems.first ?? Problem(
        name: slug,
        difficulty: .easy,
        url: "https://leetcode.com/problems/\(slug)/"
    )
}

func problemLocation(
    for slug: String,
    file: StaticString = #file,
    line: UInt = #line
) -> (problem: Problem, dayId: Int, index: Int) {
    for day in dsaPlan {
        if let index = day.problems.firstIndex(
            where: { LeetCodeSlugExtractor.extractSlug(from: $0.url) == slug }
        ) {
            return (day.problems[index], day.id, index)
        }
    }
    XCTFail("Missing problem location for slug \(slug)", file: file, line: line)
    let fallback = problemWithSlug(slug, file: file, line: line)
    return (fallback, 1, 0)
}
