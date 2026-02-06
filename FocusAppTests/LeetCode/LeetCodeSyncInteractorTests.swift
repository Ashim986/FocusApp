@testable import FocusApp
import XCTest

final class LeetCodeSyncInteractorTests: XCTestCase {
    @MainActor
    func testSyncSolvedProblemsMarksProgress() async {
        let start = makeDate(year: 2026, month: 2, day: 3)
        let storage = InMemoryAppStorage()
        let store = AppStateStore(
            storage: storage,
            calendar: PlanCalendar(startDate: start),
            dateProvider: FixedDateProvider(date: start)
        )
        let client = FakeLeetCodeClient()
        client.solvedSlugsResult = .success(["reverse-linked-list"])

        let interactor = LeetCodeSyncInteractor(appStore: store, client: client)
        let result = await interactor.syncSolvedProblems(username: "user", limit: 50)

        let expectedMatches = dsaPlan.flatMap { day in
            day.problems.enumerated().compactMap { index, problem -> (Int, Int)? in
                guard let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
                      slug == "reverse-linked-list" else { return nil }
                return (day.id, index)
            }
        }

        XCTAssertEqual(result.syncedCount, expectedMatches.count)
        XCTAssertEqual(result.totalMatched, expectedMatches.count)
        XCTAssertFalse(expectedMatches.isEmpty)
        for match in expectedMatches {
            XCTAssertTrue(store.isProblemCompleted(day: match.0, problemIndex: match.1))
        }
    }

    @MainActor
    func testValidateUsernameHandlesFailure() async {
        let store = AppStateStore(storage: InMemoryAppStorage())
        let client = FakeLeetCodeClient()
        client.validateResult = .failure(TestError())

        let interactor = LeetCodeSyncInteractor(appStore: store, client: client)
        let isValid = await interactor.validateUsername("bad")

        XCTAssertFalse(isValid)
    }
}
