import Foundation

// MARK: - Solution Index Models

/// Metadata for a single topic in the solution index
struct SolutionIndexTopic: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let name: String
    let file: String
    let problemCount: Int
    let difficulties: [String: Int]
}

/// Entry in the problem-to-topic lookup index
struct SolutionIndexEntry: Codable, Sendable, Equatable {
    let topic: String
    let number: Int?
    let difficulty: String?
}

/// Master index file loaded at app startup
struct SolutionIndex: Codable, Sendable {
    let version: String
    let lastUpdated: String
    let totalProblems: Int
    let topics: [SolutionIndexTopic]
    let problemIndex: [String: SolutionIndexEntry]
}

// MARK: - Topic Solutions Bundle

/// A single topic file containing all solutions for that topic
struct TopicSolutionsBundle: Codable, Sendable {
    let topic: String
    let version: String
    let solutions: [ProblemSolution]
}
