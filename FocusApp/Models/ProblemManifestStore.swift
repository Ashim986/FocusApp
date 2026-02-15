import Foundation

// MARK: - Problem Manifest Models

/// Represents a problem from the LeetCode manifest
struct ManifestProblem: Codable, Identifiable, Sendable {
    let number: Int
    let slug: String
    let title: String
    let difficulty: String
    let topics: [String]
    let acceptanceRate: Double

    var id: String { slug }

    /// Difficulty as enum for easier handling
    var difficultyLevel: DifficultyLevel {
        switch difficulty.lowercased() {
        case "easy": return .easy
        case "medium": return .medium
        case "hard": return .hard
        default: return .medium
        }
    }

    enum DifficultyLevel: String, Codable, Sendable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var color: String {
            switch self {
            case .easy: return "green"
            case .medium: return "orange"
            case .hard: return "red"
            }
        }
    }
}

/// The full problem manifest bundle
struct ProblemManifest: Codable, Sendable {
    let generatedAt: String
    let problems: [ManifestProblem]
}

// MARK: - Problem Manifest Store

/// Provides access to the full problem manifest (2000+ problems)
final class ProblemManifestStore: @unchecked Sendable {
    static let shared = ProblemManifestStore()

    private var problems: [ManifestProblem] = []
    private var slugToProblems: [String: ManifestProblem] = [:]
    private var topicToProblems: [String: [ManifestProblem]] = [:]
    private var generatedAt: String = ""

    var totalProblems: Int { problems.count }
    var allTopics: [String] { Array(topicToProblems.keys).sorted() }

    private init() {
        loadManifest()
    }

    private func loadManifest() {
        guard let url = Bundle.main.url(forResource: "problem-manifest", withExtension: "json") else {
            print("ProblemManifestStore: problem-manifest.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let manifest = try decoder.decode(ProblemManifest.self, from: data)

            problems = manifest.problems
            generatedAt = manifest.generatedAt
            slugToProblems = Dictionary(
                uniqueKeysWithValues: manifest.problems.map { ($0.slug, $0) }
            )

            // Build topic index
            for problem in problems {
                for topic in problem.topics {
                    topicToProblems[topic, default: []].append(problem)
                }
            }

            print("ProblemManifestStore: Loaded \(problems.count) problems across \(topicToProblems.count) topics")
        } catch {
            print("ProblemManifestStore: Failed to load manifest - \(error)")
        }
    }

    /// Get problem by slug
    func problem(for slug: String) -> ManifestProblem? {
        slugToProblems[slug]
    }

    /// Get all problems
    func allProblems() -> [ManifestProblem] {
        problems
    }

    /// Get problems by difficulty
    func problems(difficulty: ManifestProblem.DifficultyLevel) -> [ManifestProblem] {
        problems.filter { $0.difficultyLevel == difficulty }
    }

    /// Get problems by topic
    func problems(topic: String) -> [ManifestProblem] {
        topicToProblems[topic] ?? []
    }

    /// Get problems by multiple topics (intersection)
    func problems(topics: [String]) -> [ManifestProblem] {
        guard !topics.isEmpty else { return problems }
        let sets = topics.compactMap { topicToProblems[$0] }.map { Set($0.map(\.slug)) }
        guard let first = sets.first else { return [] }
        let intersection = sets.dropFirst().reduce(first) { $0.intersection($1) }
        return problems.filter { intersection.contains($0.slug) }
    }

    /// Search problems by title or slug
    func search(query: String) -> [ManifestProblem] {
        let lowercased = query.lowercased()
        return problems.filter {
            $0.title.lowercased().contains(lowercased) ||
            $0.slug.lowercased().contains(lowercased)
        }
    }

    /// Get random problems for a topic
    func randomProblems(
        topic: String,
        count: Int,
        difficulty: ManifestProblem.DifficultyLevel? = nil,
        excluding: Set<String> = []
    ) -> [ManifestProblem] {
        var candidates = problems(topic: topic)

        if let diff = difficulty {
            candidates = candidates.filter { $0.difficultyLevel == diff }
        }

        candidates = candidates.filter { !excluding.contains($0.slug) }
        return Array(candidates.shuffled().prefix(count))
    }

    /// Get problems sorted by acceptance rate (easiest first)
    func problemsByAcceptance(ascending: Bool = false) -> [ManifestProblem] {
        problems.sorted { ascending ? $0.acceptanceRate > $1.acceptanceRate : $0.acceptanceRate < $1.acceptanceRate }
    }
}

// MARK: - On-Demand Solution Provider

/// Provides solutions on-demand, falling back to template generation for unavailable solutions
final class OnDemandSolutionProvider: SolutionProviding, @unchecked Sendable {
    private let bundledStore: SolutionProviding
    private let manifestStore: ProblemManifestStore
    private var generatedSolutions: [String: ProblemSolution] = [:]
    private let lock = NSLock()

    init(
        bundledStore: SolutionProviding = BundledSolutionStore(),
        manifestStore: ProblemManifestStore = .shared
    ) {
        self.bundledStore = bundledStore
        self.manifestStore = manifestStore
    }

    func solution(for slug: String) -> ProblemSolution? {
        // First check bundled solutions
        if let bundled = bundledStore.solution(for: slug) {
            return bundled
        }

        // Check cached generated solutions
        lock.lock()
        if let generated = generatedSolutions[slug] {
            lock.unlock()
            return generated
        }
        lock.unlock()

        // Generate template if problem exists in manifest
        if let problem = manifestStore.problem(for: slug) {
            let template = generateSolutionTemplate(for: problem)
            lock.lock()
            generatedSolutions[slug] = template
            lock.unlock()
            return template
        }

        return nil
    }

    func allSolutions() -> [ProblemSolution] {
        bundledStore.allSolutions()
    }

    var solutionCount: Int {
        bundledStore.solutionCount
    }

    /// Check if a full solution (not template) is available
    func hasFullSolution(for slug: String) -> Bool {
        bundledStore.solution(for: slug) != nil
    }

    /// Get all problems that don't have full solutions yet
    func problemsWithoutSolutions() -> [ManifestProblem] {
        manifestStore.allProblems().filter { bundledStore.solution(for: $0.slug) == nil }
    }

    /// Get problems with solutions for a topic
    func problemsWithSolutions(topic: String) -> [ManifestProblem] {
        manifestStore.problems(topic: topic).filter { bundledStore.solution(for: $0.slug) != nil }
    }

    // MARK: - Template Generation

    private func generateSolutionTemplate(for problem: ManifestProblem) -> ProblemSolution {
        let approachTemplate = SolutionApproach(
            id: UUID(),
            name: "Approach TBD",
            order: 1,
            intuition: "Solution for this problem is being prepared. Check back soon!",
            approach: """
            1. Analyze the problem requirements
            2. Identify the key data structure or algorithm
            3. Implement the solution
            4. Test with edge cases
            """,
            explanation: """
            This is a \(problem.difficulty) problem involving: \(problem.topics.joined(separator: ", ")).

            Acceptance rate: \(String(format: "%.1f", problem.acceptanceRate))%
            """,
            code: generateCodeTemplate(for: problem),
            complexity: ComplexityAnalysis(
                time: "TBD",
                space: "TBD",
                timeExplanation: "Analysis pending",
                spaceExplanation: "Analysis pending"
            ),
            testCases: []
        )

        return ProblemSolution(
            id: UUID(),
            problemSlug: problem.slug,
            summary: "[\(problem.difficulty)] \(problem.title) - " +
                "Solution coming soon. Topics: \(problem.topics.joined(separator: ", "))",
            approaches: [approachTemplate],
            relatedProblems: findRelatedProblems(for: problem),
            lastUpdated: Date()
        )
    }

    private func generateCodeTemplate(for problem: ManifestProblem) -> String {
        let funcName = problem.slug.replacingOccurrences(of: "-", with: "_")
            .split(separator: "_")
            .enumerated()
            .map { $0.offset == 0 ? String($0.element) : $0.element.capitalized }
            .joined()

        return """
        // Problem #\(problem.number): \(problem.title)
        // Difficulty: \(problem.difficulty)
        // Topics: \(problem.topics.joined(separator: ", "))

        func \(funcName)(_ input: [Int]) -> Int {
            // TODO: Implement solution
            return 0
        }
        """
    }

    private func findRelatedProblems(for problem: ManifestProblem) -> [String] {
        // Find problems with similar topics
        var related: [String] = []

        for topic in problem.topics.prefix(2) {
            let sameTopicProblems = manifestStore.problems(topic: topic)
                .filter { $0.slug != problem.slug && bundledStore.solution(for: $0.slug) != nil }
                .prefix(2)
            related.append(contentsOf: sameTopicProblems.map(\.slug))
        }

        return Array(Set(related).prefix(4))
    }
}

// MARK: - Random Study Plan Generator

/// Generates randomized study plans from the problem pool
final class StudyPlanGenerator {
    private let manifestStore: ProblemManifestStore
    private let solutionProvider: OnDemandSolutionProvider

    init(
        manifestStore: ProblemManifestStore = .shared,
        solutionProvider: OnDemandSolutionProvider
    ) {
        self.manifestStore = manifestStore
        self.solutionProvider = solutionProvider
    }

    /// Generate a 25-day NeetCode-style study plan from the active bundled plan.
    func generate25DayPlan(
        preferSolved: Bool = true,
        excludingSlugs: Set<String> = []
    ) -> [GeneratedStudyDay] {
        var plan: [GeneratedStudyDay] = []
        var usedSlugs = excludingSlugs

        for day in dsaPlan {
            var dayProblems: [ManifestProblem] = []
            dayProblems.reserveCapacity(day.problems.count)

            for problem in day.problems {
                guard let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else { continue }
                guard !usedSlugs.contains(slug) else { continue }
                guard let manifest = manifestStore.problem(for: slug) else { continue }
                if preferSolved && !solutionProvider.hasFullSolution(for: slug) {
                    continue
                }
                dayProblems.append(manifest)
                usedSlugs.insert(slug)
            }

            plan.append(GeneratedStudyDay(
                day: day.id,
                topic: day.topic,
                problems: dayProblems
            ))
        }

        return plan
    }

    @available(*, deprecated, message: "Use generate25DayPlan()")
    func generate15DayPlan(
        preferSolved: Bool = true,
        excludingSlugs: Set<String> = []
    ) -> [GeneratedStudyDay] {
        generate25DayPlan(preferSolved: preferSolved, excludingSlugs: excludingSlugs)
    }
}

/// Represents a generated study day
struct GeneratedStudyDay: Identifiable, Sendable {
    let day: Int
    let topic: String
    let problems: [ManifestProblem]

    var id: Int { day }
}
