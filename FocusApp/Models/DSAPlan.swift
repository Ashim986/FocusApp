import Foundation

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

struct Problem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let difficulty: Difficulty
    let url: String
    let leetcodeNumber: Int?

    enum CodingKeys: String, CodingKey {
        case name, difficulty, url, leetcodeNumber
    }

    init(name: String, difficulty: Difficulty, url: String, leetcodeNumber: Int? = nil) {
        self.name = name
        self.difficulty = difficulty
        self.url = url
        self.leetcodeNumber = leetcodeNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.url = try container.decode(String.self, forKey: .url)
        self.leetcodeNumber = try container.decodeIfPresent(Int.self, forKey: .leetcodeNumber)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(leetcodeNumber, forKey: .leetcodeNumber)
    }

    var displayName: String {
        guard let leetcodeNumber else { return name }
        return "#\(leetcodeNumber) \(name)"
    }
}

struct Day: Identifiable, Codable {
    let id: Int
    let date: String
    let topic: String
    let problems: [Problem]
}

struct PlanData: Codable {
    let preCompletedTopics: [String]
    let days: [Day]
}

enum PlanDataLoader {
    static func load() -> PlanData {
        let locale = Locale.current.language.languageCode?.identifier
        let localizedURL = Bundle.main.url(
            forResource: "Plan",
            withExtension: "json",
            subdirectory: nil,
            localization: locale
        )

        if let url = localizedURL ?? Bundle.main.url(forResource: "Plan", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let plan = try? JSONDecoder().decode(PlanData.self, from: data) {
            return plan
        }

        return PlanFallbackBuilder.build()
    }
}

private enum PlanFallbackBuilder {
    static let dayCount = 25
    static let problemsPerDay = 6
    static let targetProblemCount = dayCount * problemsPerDay

    static func build() -> PlanData {
        let manifestStore = ProblemManifestStore.shared
        let topicStore = TopicSolutionStore(bundle: .main, subdirectory: "Solutions")
        let topics = topicStore.availableTopics

        guard !topics.isEmpty else {
            return emptyPlan
        }

        let buckets: [(topic: String, problems: [Problem])] = topics.compactMap { topic in
            var seen = Set<String>()
            var problems: [Problem] = []

            for solution in topicStore.solutions(for: topic.id) {
                let slug = solution.problemSlug
                guard seen.insert(slug).inserted else { continue }
                guard let manifest = manifestStore.problem(for: slug) else { continue }
                problems.append(
                    Problem(
                        name: manifest.title,
                        difficulty: Difficulty(manifestDifficulty: manifest.difficultyLevel),
                        url: "https://leetcode.com/problems/\(slug)/",
                        leetcodeNumber: manifest.number
                    )
                )
            }

            problems.sort { lhs, rhs in
                if lhs.difficulty != rhs.difficulty {
                    return difficultyRank(lhs.difficulty) < difficultyRank(rhs.difficulty)
                }
                return (lhs.leetcodeNumber ?? Int.max) < (rhs.leetcodeNumber ?? Int.max)
            }

            guard !problems.isEmpty else { return nil }
            return (topic: topic.name, problems: problems)
        }

        guard !buckets.isEmpty else {
            return emptyPlan
        }

        var nextIndexByTopic: [String: Int] = [:]
        var selected: [(topic: String, problem: Problem)] = []
        selected.reserveCapacity(targetProblemCount)

        while selected.count < targetProblemCount {
            var addedInPass = false

            for bucket in buckets {
                if selected.count >= targetProblemCount { break }
                let nextIndex = nextIndexByTopic[bucket.topic, default: 0]
                guard nextIndex < bucket.problems.count else { continue }
                selected.append((topic: bucket.topic, problem: bucket.problems[nextIndex]))
                nextIndexByTopic[bucket.topic] = nextIndex + 1
                addedInPass = true
            }

            if !addedInPass {
                break
            }
        }

        guard !selected.isEmpty else {
            return emptyPlan
        }

        var days: [Day] = []
        days.reserveCapacity(dayCount)

        for dayIndex in 0..<dayCount {
            let start = dayIndex * problemsPerDay
            guard start < selected.count else { break }
            let end = min(start + problemsPerDay, selected.count)
            let entries = Array(selected[start..<end])
            let dayTopics = orderedUniqueTopics(from: entries)
            let topicName = dayTopics.prefix(2).joined(separator: " + ")

            days.append(
                Day(
                    id: dayIndex + 1,
                    date: "Day \(dayIndex + 1)",
                    topic: topicName.isEmpty ? "NeetCode Practice" : topicName,
                    problems: entries.map(\.problem)
                )
            )
        }

        let preCompletedTopics = Array(orderedUniqueTopics(from: selected.prefix(12).map { $0 }).prefix(3))
        return PlanData(preCompletedTopics: preCompletedTopics, days: days)
    }

    private static func orderedUniqueTopics(
        from entries: [(topic: String, problem: Problem)]
    ) -> [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        ordered.reserveCapacity(entries.count)
        for entry in entries {
            if seen.insert(entry.topic).inserted {
                ordered.append(entry.topic)
            }
        }
        return ordered
    }

    private static func difficultyRank(_ difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy:
            return 0
        case .medium:
            return 1
        case .hard:
            return 2
        }
    }

    private static let emptyPlan = PlanData(
        preCompletedTopics: [],
        days: []
    )
}

private extension Difficulty {
    init(manifestDifficulty: ManifestProblem.DifficultyLevel) {
        switch manifestDifficulty {
        case .easy:
            self = .easy
        case .medium:
            self = .medium
        case .hard:
            self = .hard
        }
    }
}

let planData = PlanDataLoader.load()
let preCompletedTopics = planData.preCompletedTopics
let dsaPlan = planData.days
