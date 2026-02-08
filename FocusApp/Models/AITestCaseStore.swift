import Foundation

struct AITestCaseEntry: Codable {
    let id: String
    let leetCodeNumber: Int?
    let questionId: String?
    let testCases: [SolutionTestCase]
}

struct AITestCaseBundle: Codable {
    var version: String
    var updatedAt: String
    var entries: [AITestCaseEntry]
}

private struct LegacyAITestCaseBundle: Codable {
    let version: String?
    let updatedAt: String?
    let cases: [String: [SolutionTestCase]]
}

final class AITestCaseStore {
    private let fileURL: URL
    private let lock = NSLock()
    private var cache: [String: AITestCaseEntry] = [:]
    private var lastUpdatedAt: String?

    init(fileURL: URL = AITestCaseStore.defaultFileURL) {
        self.fileURL = fileURL
        loadFromDisk()
    }

    var locationURL: URL {
        fileURL
    }

    func testCases(for slug: String) -> [SolutionTestCase] {
        lock.lock()
        defer { lock.unlock() }
        return cache[slug]?.testCases ?? []
    }

    func entry(for slug: String) -> AITestCaseEntry? {
        lock.lock()
        defer { lock.unlock() }
        return cache[slug]
    }

    func summary() -> AITestCaseStoreSummary {
        lock.lock()
        let entries = cache.count
        let totalTests = cache.values.reduce(0) { $0 + $1.testCases.count }
        let updatedAt = lastUpdatedAt
        lock.unlock()
        let exists = FileManager.default.fileExists(atPath: fileURL.path)
        return AITestCaseStoreSummary(
            exists: exists,
            entryCount: entries,
            testCaseCount: totalTests,
            updatedAt: updatedAt,
            fileURL: fileURL
        )
    }

    func rawJSONString() -> String? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try? String(contentsOf: fileURL, encoding: .utf8)
    }

    func save(
        testCases: [SolutionTestCase],
        for slug: String,
        leetCodeNumber: Int?,
        questionId: String?
    ) {
        lock.lock()
        cache[slug] = AITestCaseEntry(
            id: slug,
            leetCodeNumber: leetCodeNumber,
            questionId: questionId,
            testCases: testCases
        )
        let snapshot = cache
        lock.unlock()
        persist(snapshot)
    }

    func clear(for slug: String) {
        lock.lock()
        cache.removeValue(forKey: slug)
        let snapshot = cache
        lock.unlock()
        persist(snapshot)
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            if let bundle = try? decoder.decode(AITestCaseBundle.self, from: data) {
                cache = Dictionary(uniqueKeysWithValues: bundle.entries.map { ($0.id, $0) })
                lastUpdatedAt = bundle.updatedAt
                return
            }
            let legacy = try decoder.decode(LegacyAITestCaseBundle.self, from: data)
            cache = Dictionary(
                uniqueKeysWithValues: legacy.cases.map {
                    ($0.key, AITestCaseEntry(id: $0.key, leetCodeNumber: nil, questionId: nil, testCases: $0.value))
                }
            )
            lastUpdatedAt = legacy.updatedAt
        } catch {
            print("AITestCaseStore: Failed to load - \(error)")
        }
    }

    private func persist(_ cases: [String: AITestCaseEntry]) {
        do {
            let updatedAt = ISO8601DateFormatter().string(from: Date())
            let bundle = AITestCaseBundle(
                version: "1.1",
                updatedAt: updatedAt,
                entries: cases.values.sorted { $0.id < $1.id }
            )
            let data = try JSONEncoder().encode(bundle)
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            lock.lock()
            lastUpdatedAt = updatedAt
            lock.unlock()
        } catch {
            print("AITestCaseStore: Failed to save - \(error)")
        }
    }

    static var defaultFileURL: URL {
        let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let dir = base.appendingPathComponent("FocusApp", isDirectory: true)
        return dir.appendingPathComponent("ai-testcases.json")
    }
}

struct AITestCaseStoreSummary {
    let exists: Bool
    let entryCount: Int
    let testCaseCount: Int
    let updatedAt: String?
    let fileURL: URL
}
