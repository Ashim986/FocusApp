#!/usr/bin/env swift

import Foundation

// MARK: - Models (copied from app for standalone execution)

struct LeetCodeTopicTag: Codable {
    let name: String
    let slug: String
}

struct LeetCodeProblemItem: Codable {
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
}

struct LeetCodeProblemsetData: Decodable {
    let problemsetQuestionList: LeetCodeProblemsetQuestionList?
}

struct LeetCodeProblemsetQuestionList: Decodable {
    let total: Int
    let questions: [LeetCodeProblemItem]
}

struct LeetCodeGraphQLError: Decodable {
    let message: String
}

struct LeetCodeGraphQLResponse<T: Decodable>: Decodable {
    let data: T?
    let errors: [LeetCodeGraphQLError]?
}

// MARK: - Problem Manifest

struct ProblemManifest: Codable {
    let version: String
    let generatedAt: Date
    let totalProblems: Int
    let problems: [ProblemManifestEntry]

    struct ProblemManifestEntry: Codable {
        let number: Int
        let title: String
        let slug: String
        let difficulty: String
        let topics: [String]
        let acceptanceRate: Double
    }
}

// MARK: - Fetcher

class LeetCodeProblemFetcher {
    private let graphQLURL: URL = {
        guard let url = URL(string: "https://leetcode.com/graphql") else {
            return URL(fileURLWithPath: "/")
        }
        return url
    }()
    private let session = URLSession.shared

    func fetchProblems(
        skip: Int,
        limit: Int,
        difficulty: String?
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

        let body = try JSONSerialization.data(withJSONObject: [
            "query": query,
            "variables": variables
        ])

        var request = URLRequest(url: graphQLURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("FocusApp/1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = body

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(LeetCodeGraphQLResponse<LeetCodeProblemsetData>.self, from: data)

        if let errors = response.errors, !errors.isEmpty {
            throw NSError(
                domain: "LeetCode",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: errors.map(\.message).joined(separator: "; ")]
            )
        }

        guard let problemset = response.data?.problemsetQuestionList else {
            return ([], 0)
        }

        return (problemset.questions, problemset.total)
    }

    func fetchAllProblems(difficulty: String?) async throws -> [LeetCodeProblemItem] {
        var allProblems: [LeetCodeProblemItem] = []
        var skip = 0
        let batchSize = 100

        print("Fetching \(difficulty ?? "all") problems...")

        let (firstBatch, total) = try await fetchProblems(skip: 0, limit: batchSize, difficulty: difficulty)
        allProblems.append(contentsOf: firstBatch)
        print("  Fetched \(allProblems.count)/\(total)...")
        skip += batchSize

        while skip < total {
            try await Task.sleep(nanoseconds: 500_000_000) // 500ms delay
            let (batch, _) = try await fetchProblems(skip: skip, limit: batchSize, difficulty: difficulty)
            allProblems.append(contentsOf: batch)
            print("  Fetched \(allProblems.count)/\(total)...")
            skip += batchSize
        }

        return allProblems
    }
}

// MARK: - Main execution

func runFetcher() async {
    let fetcher = LeetCodeProblemFetcher()

    do {
        print("=== LeetCode Problem Fetcher ===\n")

        // Fetch Easy problems
        let easyProblems = try await fetcher.fetchAllProblems(difficulty: "EASY")
        print("\n✓ Found \(easyProblems.count) Easy problems")

        // Small delay between difficulty fetches
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Fetch Medium problems
        let mediumProblems = try await fetcher.fetchAllProblems(difficulty: "MEDIUM")
        print("\n✓ Found \(mediumProblems.count) Medium problems")

        // Combine and filter out paid-only
        let allProblems = (easyProblems + mediumProblems).filter { !$0.isPaidOnly }
        print("\n✓ Total free problems: \(allProblems.count)")

        // Create manifest
        let entries = allProblems.map { problem in
            ProblemManifest.ProblemManifestEntry(
                number: problem.questionNumber ?? 0,
                title: problem.title,
                slug: problem.titleSlug,
                difficulty: problem.difficulty,
                topics: problem.topicTags.map(\.name),
                acceptanceRate: problem.acRate
            )
        }.sorted { $0.number < $1.number }

        let manifest = ProblemManifest(
            version: "1.0.0",
            generatedAt: Date(),
            totalProblems: entries.count,
            problems: entries
        )

        // Save manifest
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(manifest)

        let outputPath = FileManager.default.currentDirectoryPath + "/problem-manifest.json"
        try data.write(to: URL(fileURLWithPath: outputPath))

        print("\n✓ Manifest saved to: \(outputPath)")

        // Print topic summary
        var topicCounts: [String: Int] = [:]
        for problem in entries {
            for topic in problem.topics {
                topicCounts[topic, default: 0] += 1
            }
        }

        print("\n=== Topic Summary ===")
        for (topic, count) in topicCounts.sorted(by: { $0.value > $1.value }).prefix(20) {
            print("  \(topic): \(count) problems")
        }

    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

// Run the async function
let semaphore = DispatchSemaphore(value: 0)
Task {
    await runFetcher()
    semaphore.signal()
}
semaphore.wait()
