import FocusNetworking
import XCTest

@MainActor
final class DebugLogStoreTests: XCTestCase {
    func testRecordInsertsNewestFirst() {
        let store = DebugLogStore(maxEntries: 10)
        let first = DebugLogEntry(
            level: .info,
            category: .network,
            title: "First",
            message: "one"
        )
        let second = DebugLogEntry(
            level: .warning,
            category: .network,
            title: "Second",
            message: "two"
        )

        store.record(first)
        store.record(second)

        XCTAssertEqual(store.entries.count, 2)
        XCTAssertEqual(store.entries[0].title, "Second")
        XCTAssertEqual(store.entries[1].title, "First")
    }

    func testRecordHonorsMaxEntriesLimit() {
        let store = DebugLogStore(maxEntries: 2)

        store.record(DebugLogEntry(level: .info, category: .app, title: "1", message: "1"))
        store.record(DebugLogEntry(level: .info, category: .app, title: "2", message: "2"))
        store.record(DebugLogEntry(level: .info, category: .app, title: "3", message: "3"))

        XCTAssertEqual(store.entries.count, 2)
        XCTAssertEqual(store.entries[0].title, "3")
        XCTAssertEqual(store.entries[1].title, "2")
    }

    func testRecordAsyncAppendsEntry() async {
        let store = DebugLogStore(maxEntries: 5)
        let entry = DebugLogEntry(
            level: .error,
            category: .network,
            title: "Async",
            message: "message"
        )

        store.recordAsync(entry)

        // recordAsync hops to MainActor via Task.
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].title, "Async")
    }
}
