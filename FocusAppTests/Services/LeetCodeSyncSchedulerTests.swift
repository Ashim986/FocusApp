@testable import FocusApp
import XCTest

final class LeetCodeSyncSchedulerTests: XCTestCase {
    @MainActor
    func testSyncNowUsesCurrentUsername() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        store.updateLeetCodeUsername("tester")
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        await scheduler.syncNow(trigger: .hourly)

        XCTAssertEqual(spy.calls.count, 1)
        XCTAssertEqual(spy.calls.first?.username, "tester")
        XCTAssertEqual(spy.calls.first?.limit, LeetCodeConstants.recentSubmissionsLimit)
    }

    @MainActor
    func testHandleUsernameChangeTriggersSync() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        store.updateLeetCodeUsername("newuser")
        scheduler.handleUsernameChange("newuser")
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(spy.calls.count, 1)
        XCTAssertEqual(spy.calls.first?.username, "newuser")
    }

    @MainActor
    func testSyncNowSkipsWhenUsernameEmpty() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        store.updateLeetCodeUsername("")
        await scheduler.syncNow(trigger: .hourly)

        XCTAssertTrue(spy.calls.isEmpty)
    }

    @MainActor
    func testHandleUsernameChangeSkipsEmpty() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        scheduler.handleUsernameChange("   ")
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(spy.calls.isEmpty)
    }

    @MainActor
    func testStartAndStopAreIdempotent() {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        scheduler.start()
        scheduler.start()
        scheduler.stop()
        scheduler.stop()
    }

    @MainActor
    func testStartObservesUsernameChanges() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        let spy = SpyLeetCodeSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: spy)

        scheduler.start()
        store.updateLeetCodeUsername("observed")
        try? await Task.sleep(nanoseconds: 50_000_000)
        scheduler.stop()

        XCTAssertEqual(spy.calls.first?.username, "observed")
    }

    @MainActor
    func testSyncNowSkipsWhenAlreadySyncing() async {
        let storage = InMemoryAppStorage()
        let store = AppStateStore(storage: storage)
        store.updateLeetCodeUsername("tester")
        let syncer = BlockingSyncer()
        let scheduler = LeetCodeSyncScheduler(appStore: store, syncer: syncer)
        let started = expectation(description: "sync started")
        syncer.onCall = { started.fulfill() }

        let task = Task { await scheduler.syncNow(trigger: .hourly) }
        await fulfillment(of: [started], timeout: 1.0)

        await scheduler.syncNow(trigger: .dayStart)
        XCTAssertEqual(syncer.calls.count, 1)

        syncer.resume()
        _ = await task.value
    }
}

final class SpyLeetCodeSyncer: LeetCodeSyncing {
    struct Call {
        let username: String
        let limit: Int
    }

    private(set) var calls: [Call] = []

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        calls.append(Call(username: username, limit: limit))
        return LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
    }
}

@MainActor
final class BlockingSyncer: LeetCodeSyncing {
    struct Call {
        let username: String
        let limit: Int
    }

    var calls: [Call] = []
    var onCall: (() -> Void)?
    private var continuation: CheckedContinuation<Void, Never>?

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        calls.append(Call(username: username, limit: limit))
        onCall?()
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
        return LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
    }

    func resume() {
        continuation?.resume()
        continuation = nil
    }
}
