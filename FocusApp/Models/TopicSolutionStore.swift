import Foundation

/// Solution store that loads solutions from topic-partitioned JSON files.
///
/// Loads `index.json` eagerly at init, then lazily loads each topic file
/// on first access to a slug belonging to that topic.
final class TopicSolutionStore: SolutionProviding, @unchecked Sendable {
    private let index: SolutionIndex
    private var loadedTopics: [String: [String: ProblemSolution]] = [:]
    private let lock = NSLock()
    private let bundle: Bundle
    private let subdirectory: String?

    init(bundle: Bundle = .main, subdirectory: String? = nil) {
        self.bundle = bundle
        self.subdirectory = subdirectory

        guard let url = bundle.url(
            forResource: "index",
            withExtension: "json",
            subdirectory: subdirectory
        ) else {
            print("TopicSolutionStore: index.json not found in bundle")
            self.index = SolutionIndex(
                version: "0.0.0",
                lastUpdated: "",
                totalProblems: 0,
                topics: [],
                problemIndex: [:]
            )
            return
        }

        do {
            let data = try Data(contentsOf: url)
            self.index = try JSONDecoder().decode(SolutionIndex.self, from: data)
            print("TopicSolutionStore: Loaded index with \(self.index.totalProblems) problems across \(self.index.topics.count) topics (v\(self.index.version))")
        } catch {
            print("TopicSolutionStore: Failed to decode index.json - \(error)")
            self.index = SolutionIndex(
                version: "0.0.0",
                lastUpdated: "",
                totalProblems: 0,
                topics: [],
                problemIndex: [:]
            )
        }
    }

    // MARK: - SolutionProviding

    func solution(for slug: String) -> ProblemSolution? {
        guard let entry = index.problemIndex[slug] else { return nil }
        ensureTopicLoaded(entry.topic)
        lock.lock()
        let result = loadedTopics[entry.topic]?[slug]
        lock.unlock()
        return result
    }

    func allSolutions() -> [ProblemSolution] {
        loadAllTopics()
        lock.lock()
        let all = loadedTopics.values.flatMap(\.values)
        lock.unlock()
        return all
    }

    var solutionCount: Int {
        index.totalProblems
    }

    // MARK: - Topic Queries

    /// All available topics from the index
    var availableTopics: [SolutionIndexTopic] {
        index.topics
    }

    /// Index version
    var version: String {
        index.version
    }

    /// All solutions for a given topic ID
    func solutions(for topicId: String) -> [ProblemSolution] {
        ensureTopicLoaded(topicId)
        lock.lock()
        let result = loadedTopics[topicId].map { Array($0.values) } ?? []
        lock.unlock()
        return result
    }

    /// Check if a slug exists in the index (without loading the topic file)
    func hasSolution(for slug: String) -> Bool {
        index.problemIndex[slug] != nil
    }

    // MARK: - Private

    private func ensureTopicLoaded(_ topicId: String) {
        lock.lock()
        let alreadyLoaded = loadedTopics[topicId] != nil
        lock.unlock()
        guard !alreadyLoaded else { return }
        loadTopicFile(topicId)
    }

    private func loadTopicFile(_ topicId: String) {
        guard let topicMeta = index.topics.first(where: { $0.id == topicId }) else { return }

        let filename = topicMeta.file.replacingOccurrences(of: ".json", with: "")
        guard let url = bundle.url(
            forResource: filename,
            withExtension: "json",
            subdirectory: subdirectory
        ) else {
            print("TopicSolutionStore: \(topicMeta.file) not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let topicBundle = try decoder.decode(TopicSolutionsBundle.self, from: data)
            let map = Dictionary(
                uniqueKeysWithValues: topicBundle.solutions.map { ($0.problemSlug, $0) }
            )
            lock.lock()
            loadedTopics[topicId] = map
            lock.unlock()
        } catch {
            print("TopicSolutionStore: Failed to load \(topicMeta.file) - \(error)")
        }
    }

    private func loadAllTopics() {
        for topic in index.topics {
            ensureTopicLoaded(topic.id)
        }
    }
}
