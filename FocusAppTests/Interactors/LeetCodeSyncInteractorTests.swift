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

        XCTAssertEqual(result.syncedCount, 1)
        XCTAssertEqual(result.totalMatched, 1)
        XCTAssertTrue(store.isProblemCompleted(day: 1, problemIndex: 0))
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
