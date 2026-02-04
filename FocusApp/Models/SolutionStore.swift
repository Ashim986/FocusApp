import Foundation

// MARK: - Solution Providing Protocol

/// Protocol for accessing problem solutions
protocol SolutionProviding: Sendable {
    /// Returns the solution for a given problem slug
    func solution(for slug: String) -> ProblemSolution?

    /// Returns all available solutions
    func allSolutions() -> [ProblemSolution]

    /// Returns the total number of solutions
    var solutionCount: Int { get }
}

// MARK: - Bundled Solution Store

/// Loads and provides access to solutions bundled with the app
final class BundledSolutionStore: SolutionProviding, @unchecked Sendable {
    private var solutionsMap: [String: ProblemSolution] = [:]
    private var allSolutionsList: [ProblemSolution] = []

    init() {
        loadSolutions()
    }

    private func loadSolutions() {
        guard let url = Bundle.main.url(forResource: "Solutions", withExtension: "json") else {
            print("BundledSolutionStore: Solutions.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let bundle = try decoder.decode(SolutionsBundle.self, from: data)

            allSolutionsList = bundle.solutions
            solutionsMap = Dictionary(
                uniqueKeysWithValues: bundle.solutions.map { ($0.problemSlug, $0) }
            )

            print("BundledSolutionStore: Loaded \(solutionCount) solutions (v\(bundle.version))")
        } catch {
            print("BundledSolutionStore: Failed to load solutions - \(error)")
        }
    }

    func solution(for slug: String) -> ProblemSolution? {
        solutionsMap[slug]
    }

    func allSolutions() -> [ProblemSolution] {
        allSolutionsList
    }

    var solutionCount: Int {
        allSolutionsList.count
    }
}

// MARK: - In-Memory Solution Store (for testing)

/// In-memory solution store for testing purposes
final class InMemorySolutionStore: SolutionProviding, @unchecked Sendable {
    private var solutions: [String: ProblemSolution]

    init(solutions: [ProblemSolution] = []) {
        self.solutions = Dictionary(
            uniqueKeysWithValues: solutions.map { ($0.problemSlug, $0) }
        )
    }

    func solution(for slug: String) -> ProblemSolution? {
        solutions[slug]
    }

    func allSolutions() -> [ProblemSolution] {
        Array(solutions.values)
    }

    var solutionCount: Int {
        solutions.count
    }

    /// Adds or updates a solution (for testing)
    func addSolution(_ solution: ProblemSolution) {
        solutions[solution.problemSlug] = solution
    }
}
