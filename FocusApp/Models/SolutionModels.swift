import Foundation

// MARK: - Complexity Analysis

/// Represents the complexity analysis for a solution approach
struct ComplexityAnalysis: Codable, Equatable, Sendable {
    let time: String
    let space: String
    let timeExplanation: String?
    let spaceExplanation: String?

    init(
        time: String,
        space: String,
        timeExplanation: String? = nil,
        spaceExplanation: String? = nil
    ) {
        self.time = time
        self.space = space
        self.timeExplanation = timeExplanation
        self.spaceExplanation = spaceExplanation
    }
}

// MARK: - Solution Test Case

/// A test case attached to a solution approach
struct SolutionTestCase: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let input: String
    let expectedOutput: String
    let explanation: String?
    /// Whether the order of elements in the output matters for comparison.
    /// When `false`, array outputs like `[1,2]` and `[2,1]` are treated as equivalent.
    /// Defaults to `true` for backward compatibility with cached JSON.
    let orderMatters: Bool

    init(
        id: UUID = UUID(),
        input: String,
        expectedOutput: String,
        explanation: String? = nil,
        orderMatters: Bool = true
    ) {
        self.id = id
        self.input = input
        self.expectedOutput = expectedOutput
        self.explanation = explanation
        self.orderMatters = orderMatters
    }

    // Backward-compatible decoding: older JSON without orderMatters defaults to true
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        input = try container.decode(String.self, forKey: .input)
        expectedOutput = try container.decode(String.self, forKey: .expectedOutput)
        explanation = try? container.decode(String.self, forKey: .explanation)
        orderMatters = (try? container.decode(Bool.self, forKey: .orderMatters)) ?? true
    }
}

// MARK: - Solution Approach

/// Represents a single approach to solving a problem
struct SolutionApproach: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let order: Int
    let intuition: String
    let approach: String
    let explanation: String
    let code: String
    let complexity: ComplexityAnalysis
    let testCases: [SolutionTestCase]

    init(
        id: UUID = UUID(),
        name: String,
        order: Int,
        intuition: String,
        approach: String,
        explanation: String,
        code: String,
        complexity: ComplexityAnalysis,
        testCases: [SolutionTestCase] = []
    ) {
        self.id = id
        self.name = name
        self.order = order
        self.intuition = intuition
        self.approach = approach
        self.explanation = explanation
        self.code = code
        self.complexity = complexity
        self.testCases = testCases
    }
}

// MARK: - Problem Solution

/// Complete solution for a problem
struct ProblemSolution: Codable, Equatable, Identifiable, Sendable {
    let id: UUID
    let problemSlug: String
    let summary: String
    let approaches: [SolutionApproach]
    let relatedProblems: [String]?
    let lastUpdated: Date

    init(
        id: UUID = UUID(),
        problemSlug: String,
        summary: String,
        approaches: [SolutionApproach],
        relatedProblems: [String]? = nil,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.problemSlug = problemSlug
        self.summary = summary
        self.approaches = approaches
        self.relatedProblems = relatedProblems
        self.lastUpdated = lastUpdated
    }

    /// Returns approaches sorted by order
    var sortedApproaches: [SolutionApproach] {
        approaches.sorted { $0.order < $1.order }
    }
}

// MARK: - Solutions Bundle

/// Container for all solutions (for JSON bundle loading)
struct SolutionsBundle: Codable, Sendable {
    let version: String
    let solutions: [ProblemSolution]
}
