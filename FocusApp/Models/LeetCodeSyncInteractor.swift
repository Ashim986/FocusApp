import Foundation

struct LeetCodeSyncResult {
    let syncedCount: Int
    let totalMatched: Int
}

@MainActor
final class LeetCodeSyncInteractor {
    private let appStore: AppStateStore
    private let client: LeetCodeClientProtocol
    private let logger: DebugLogRecording?

    init(
        appStore: AppStateStore,
        client: LeetCodeClientProtocol,
        logger: DebugLogRecording? = nil
    ) {
        self.appStore = appStore
        self.client = client
        self.logger = logger
    }

    func validateUsername(_ username: String) async -> Bool {
        do {
            return try await client.validateUsername(username)
        } catch {
            return false
        }
    }

    func syncSolvedProblems(username: String, limit: Int) async -> LeetCodeSyncResult {
        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .sync,
                title: "Sync started",
                message: "Fetching solved problems",
                metadata: [
                    "username": username,
                    "limit": "\(limit)"
                ]
            )
        )
        do {
            let solved = try await client.fetchSolvedSlugs(username: username, limit: limit)
            let result = appStore.applySolvedSlugs(solved)
            logger?.recordAsync(
                DebugLogEntry(
                    level: .info,
                    category: .sync,
                    title: "Sync complete",
                    message: "Updated progress",
                    metadata: [
                        "matched": "\(result.totalMatched)",
                        "new": "\(result.syncedCount)"
                    ]
                )
            )
            return LeetCodeSyncResult(syncedCount: result.syncedCount, totalMatched: result.totalMatched)
        } catch {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .sync,
                    title: "Sync failed",
                    message: "Unable to fetch solved problems",
                    metadata: [
                        "error": error.localizedDescription
                    ]
                )
            )
            return LeetCodeSyncResult(syncedCount: 0, totalMatched: 0)
        }
    }
}
