import Foundation

// MARK: - Problem List Models

/// Represents a LeetCode problem from the problemset query
struct LeetCodeProblemItem: Codable, Identifiable, Sendable {
    var id: String { titleSlug }

    let frontendQuestionId: String
    let title: String
    let titleSlug: String
    let difficulty: String
    let topicTags: [LeetCodeTopicTag]
    let isPaidOnly: Bool
    let acRate: Double

    var questionNumber: Int? {
        Int(frontendQuestionId)
    }

    var difficultyLevel: Difficulty? {
        switch difficulty.lowercased() {
        case "easy": return .easy
        case "medium": return .medium
        default: return nil
        }
    }
}

struct LeetCodeTopicTag: Codable, Sendable {
    let name: String
    let slug: String
}

// MARK: - GraphQL Response Models

struct LeetCodeProblemsetData: Decodable {
    let problemsetQuestionList: LeetCodeProblemsetQuestionList?
}

struct LeetCodeProblemsetQuestionList: Decodable {
    let total: Int
    let questions: [LeetCodeProblemItem]
}

// MARK: - Problem Fetcher

/// Fetches all LeetCode problems with metadata
final class LeetCodeProblemFetcher: @unchecked Sendable {
    private let client: LeetCodeRestClient

    init(client: LeetCodeRestClient) {
        self.client = client
    }

    /// Convenience initializer with default client
    init() {
        let requestBuilder = DefaultRequestBuilder()
        let executor = URLSessionRequestExecutor()
        self.client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.baseURL,
            graphQLURL: LeetCodeConstants.graphQLBaseURL,
            requestBuilder: requestBuilder,
            executor: executor
        )
    }

    /// Fetch problems with pagination
    /// - Parameters:
    ///   - skip: Number of problems to skip
    ///   - limit: Maximum problems to fetch (max 100 per request)
    ///   - difficulty: Filter by difficulty ("EASY", "MEDIUM", "HARD", or nil for all)
    /// - Returns: List of problems and total count
    func fetchProblems(
        skip: Int = 0,
        limit: Int = 100,
        difficulty: String? = nil
    ) async throws -> (problems: [LeetCodeProblemItem], total: Int) {
        var filters: [String: Any] = [:]
        if let difficulty {
            filters["difficulty"] = difficulty
        }

        let query = """
        query problemsetQuestionList(
          $categorySlug: String,
          $limit: Int,
          $skip: Int,
          $filters: QuestionListFilterInput
        ) {
          problemsetQuestionList: questionList(
            categorySlug: $categorySlug
            limit: $limit
            skip: $skip
            filters: $filters
          ) {
            total: totalNum
            questions: data {
              frontendQuestionId: questionFrontendId
              title
              titleSlug
              difficulty
              topicTags {
                name
                slug
              }
              isPaidOnly
              acRate
            }
          }
        }
        """

        var variables: [String: Any] = [
            "categorySlug": "all-code-essentials",
            "limit": limit,
            "skip": skip
        ]

        if !filters.isEmpty {
            variables["filters"] = filters
        }

        let request = try client.makeGraphQLRequest(query: query, variables: variables)
        let data = try await client.executor.execute(request)

        let response = try client.decoder.decode(
            LeetCodeGraphQLResponse<LeetCodeProblemsetData>.self,
            from: data
        )

        if let errors = response.errors, !errors.isEmpty {
            let message = errors.map(\.message).joined(separator: "; ")
            throw LeetCodeError.graphQLError(message)
        }

        guard let problemset = response.data?.problemsetQuestionList else {
            return ([], 0)
        }

        return (problemset.questions, problemset.total)
    }

    /// Fetch all problems of a specific difficulty
    /// - Parameter difficulty: "EASY", "MEDIUM", or nil for all
    /// - Returns: All problems matching the criteria
    func fetchAllProblems(difficulty: String? = nil) async throws -> [LeetCodeProblemItem] {
        var allProblems: [LeetCodeProblemItem] = []
        var skip = 0
        let batchSize = 100

        // First fetch to get total
        let (firstBatch, total) = try await fetchProblems(skip: 0, limit: batchSize, difficulty: difficulty)
        allProblems.append(contentsOf: firstBatch)
        skip += batchSize

        // Fetch remaining in batches
        while skip < total {
            // Rate limiting - wait 500ms between requests
            try await Task.sleep(nanoseconds: 500_000_000)

            let (batch, _) = try await fetchProblems(skip: skip, limit: batchSize, difficulty: difficulty)
            allProblems.append(contentsOf: batch)
            skip += batchSize
        }

        return allProblems
    }

    /// Fetch all Easy and Medium problems (excluding paid-only)
    func fetchEasyAndMediumProblems() async throws -> [LeetCodeProblemItem] {
        async let easyProblems = fetchAllProblems(difficulty: "EASY")
        async let mediumProblems = fetchAllProblems(difficulty: "MEDIUM")

        let (easy, medium) = try await (easyProblems, mediumProblems)
        let combined = easy + medium

        // Filter out paid-only problems
        return combined.filter { !$0.isPaidOnly }
    }
}

// MARK: - Problem Manifest

/// A manifest of all available problems for solution generation
struct ProblemManifest: Codable, Sendable {
    let version: String
    let generatedAt: Date
    let totalProblems: Int
    let problems: [ProblemManifestEntry]

    struct ProblemManifestEntry: Codable, Sendable, Identifiable {
        var id: String { slug }

        let number: Int
        let title: String
        let slug: String
        let difficulty: String
        let topics: [String]
        let acceptanceRate: Double
        let hasSolution: Bool

        init(from problem: LeetCodeProblemItem, hasSolution: Bool = false) {
            self.number = problem.questionNumber ?? 0
            self.title = problem.title
            self.slug = problem.titleSlug
            self.difficulty = problem.difficulty
            self.topics = problem.topicTags.map(\.name)
            self.acceptanceRate = problem.acRate
            self.hasSolution = hasSolution
        }
    }

    /// Group problems by primary topic
    var problemsByTopic: [String: [ProblemManifestEntry]] {
        var grouped: [String: [ProblemManifestEntry]] = [:]
        for problem in problems {
            let topic = problem.topics.first ?? "Uncategorized"
            grouped[topic, default: []].append(problem)
        }
        return grouped
    }

    /// Get problems without solutions
    var problemsWithoutSolutions: [ProblemManifestEntry] {
        problems.filter { !$0.hasSolution }
    }
}

// MARK: - Manifest Generator

extension LeetCodeProblemFetcher {
    /// Generate a problem manifest from LeetCode
    /// - Parameter existingSolutions: Set of slugs that already have solutions
    func generateManifest(existingSolutions: Set<String> = []) async throws -> ProblemManifest {
        let problems = try await fetchEasyAndMediumProblems()

        let entries = problems.map { problem in
            ProblemManifest.ProblemManifestEntry(
                from: problem,
                hasSolution: existingSolutions.contains(problem.titleSlug)
            )
        }.sorted { $0.number < $1.number }

        return ProblemManifest(
            version: "1.0.0",
            generatedAt: Date(),
            totalProblems: entries.count,
            problems: entries
        )
    }

    /// Save manifest to file
    func saveManifest(_ manifest: ProblemManifest, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(manifest)
        try data.write(to: url)
    }
}
