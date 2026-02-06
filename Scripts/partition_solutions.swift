#!/usr/bin/env swift

import Foundation

// MARK: - Models

struct ComplexityAnalysis: Codable {
    let time: String
    let space: String
    let timeExplanation: String?
    let spaceExplanation: String?
}

struct SolutionTestCase: Codable {
    let id: String
    let input: String
    let expectedOutput: String
    let explanation: String?
}

struct RawTestCase: Codable {
    let id: String?
    let input: String
    let expectedOutput: String
    let explanation: String?

    func normalized() -> SolutionTestCase {
        SolutionTestCase(
            id: id ?? UUID().uuidString.lowercased(),
            input: input,
            expectedOutput: expectedOutput,
            explanation: explanation
        )
    }
}

struct SolutionApproach: Codable {
    let id: String
    let name: String
    let order: Int
    let intuition: String
    let approach: String
    let explanation: String
    let code: String
    let complexity: ComplexityAnalysis
    let testCases: [SolutionTestCase]
}

struct RawApproach: Codable {
    let id: String?
    let name: String
    let order: Int?
    let intuition: String
    let approach: String
    let explanation: String
    let code: String
    let complexity: ComplexityAnalysis
    let testCases: [RawTestCase]?

    func normalized(index: Int) -> SolutionApproach {
        SolutionApproach(
            id: id ?? UUID().uuidString.lowercased(),
            name: name,
            order: order ?? (index + 1),
            intuition: intuition,
            approach: approach,
            explanation: explanation,
            code: code,
            complexity: complexity,
            testCases: (testCases ?? []).map { $0.normalized() }
        )
    }
}

struct ProblemSolution: Codable {
    let id: String
    let problemSlug: String
    let summary: String
    let approaches: [SolutionApproach]
    let relatedProblems: [String]?
    let lastUpdated: String
}

// Slug-keyed entry (may lack id, problemSlug, lastUpdated, and approaches may lack ids)
struct SlugKeyedSolution: Codable {
    let summary: String
    let approaches: [RawApproach]
    let relatedProblems: [String]?
}

struct ManifestProblem: Codable {
    let number: Int
    let slug: String
    let title: String
    let difficulty: String
    let topics: [String]
    let acceptanceRate: Double
}

struct ProblemManifest: Codable {
    let generatedAt: String
    let problems: [ManifestProblem]
}

// Output models
struct SolutionIndexTopic: Codable {
    let id: String
    let name: String
    let file: String
    let problemCount: Int
    let difficulties: [String: Int]
}

struct SolutionIndexEntry: Codable {
    let topic: String
    let number: Int?
    let difficulty: String?
}

struct SolutionIndexFile: Codable {
    let version: String
    let lastUpdated: String
    let totalProblems: Int
    let topics: [SolutionIndexTopic]
    let problemIndex: [String: SolutionIndexEntry]
}

struct TopicSolutionsBundle: Codable {
    let topic: String
    let version: String
    let solutions: [ProblemSolution]
}

// MARK: - Topic Mapping (from ProblemManifestStore.swift)

struct TopicDef {
    let id: String
    let name: String
    let leetCodeTopics: [String]
}

let neetcodeTopics: [TopicDef] = [
    TopicDef(id: "arrays-hashing", name: "Arrays & Hashing", leetCodeTopics: ["Array", "Hash Table"]),
    TopicDef(id: "two-pointers", name: "Two Pointers", leetCodeTopics: ["Two Pointers"]),
    TopicDef(id: "sliding-window", name: "Sliding Window", leetCodeTopics: ["Sliding Window"]),
    TopicDef(id: "stack", name: "Stack", leetCodeTopics: ["Stack", "Monotonic Stack"]),
    TopicDef(id: "binary-search", name: "Binary Search", leetCodeTopics: ["Binary Search"]),
    TopicDef(id: "linked-list", name: "Linked List", leetCodeTopics: ["Linked List"]),
    TopicDef(id: "trees", name: "Trees", leetCodeTopics: ["Tree", "Binary Tree", "Binary Search Tree"]),
    TopicDef(id: "tries", name: "Tries", leetCodeTopics: ["Trie"]),
    TopicDef(id: "heap-priority-queue", name: "Heap / Priority Queue", leetCodeTopics: ["Heap (Priority Queue)"]),
    TopicDef(id: "backtracking", name: "Backtracking", leetCodeTopics: ["Backtracking"]),
    TopicDef(id: "graphs", name: "Graphs", leetCodeTopics: ["Graph", "Depth-First Search", "Breadth-First Search"]),
    TopicDef(id: "dynamic-programming", name: "Dynamic Programming", leetCodeTopics: ["Dynamic Programming"]),
    TopicDef(id: "greedy", name: "Greedy", leetCodeTopics: ["Greedy"]),
    TopicDef(id: "intervals", name: "Intervals", leetCodeTopics: ["Line Sweep"]),
    TopicDef(id: "math-geometry", name: "Math & Geometry", leetCodeTopics: ["Math", "Geometry"]),
    TopicDef(id: "bit-manipulation", name: "Bit Manipulation", leetCodeTopics: ["Bit Manipulation"])
]

// Build reverse lookup: LeetCode topic -> NeetCode topic ID
// Use priority order (first match wins)
func buildTopicAssignment() -> [String: String] {
    var mapping: [String: String] = [:]
    for topicDef in neetcodeTopics {
        for lcTopic in topicDef.leetCodeTopics where mapping[lcTopic] == nil {
            // Don't overwrite - first NeetCode topic to claim a LC topic wins
            mapping[lcTopic] = topicDef.id
        }
    }
    return mapping
}

// Generic LC topics that are too broad — only use as fallback
let genericTopics: Set<String> = [
    "Array", "Hash Table", "String",
    "Depth-First Search", "Breadth-First Search"
]

// Manual overrides for well-known problems that don't classify well automatically
let slugOverrides: [String: String] = [
    // Intervals
    "insert-interval": "intervals",
    "merge-intervals": "intervals",
    "non-overlapping-intervals": "intervals",
    "meeting-rooms": "intervals",
    "meeting-rooms-ii": "intervals",
    // Sliding window
    "find-all-anagrams-in-a-string": "sliding-window",
    "permutation-in-string": "sliding-window",
    "longest-repeating-character-replacement": "sliding-window",
    "longest-substring-without-repeating-characters": "sliding-window",
    "minimum-window-substring": "sliding-window",
    "sliding-window-maximum": "sliding-window",
    "contains-duplicate-ii": "sliding-window",
    // Two pointers
    "3sum": "two-pointers",
    "container-with-most-water": "two-pointers",
    "trapping-rain-water": "two-pointers",
    "move-zeroes": "two-pointers",
    "remove-duplicates-from-sorted-array": "two-pointers",
    "sort-colors": "two-pointers",
    "squares-of-a-sorted-array": "two-pointers",
    "next-permutation": "two-pointers",
    "rotate-array": "two-pointers",
    // Stack
    "valid-parentheses": "stack",
    "evaluate-reverse-polish-notation": "stack",
    "daily-temperatures": "stack",
    "car-fleet": "stack",
    "asteroid-collision": "stack",
    "largest-rectangle-in-histogram": "stack",
    "next-greater-element-i": "stack",
    "basic-calculator": "stack",
    "basic-calculator-ii": "stack",
    "decode-string": "stack",
    "min-stack": "stack",
    // Binary search
    "binary-search": "binary-search",
    "search-in-rotated-sorted-array": "binary-search",
    "find-minimum-in-rotated-sorted-array": "binary-search",
    "search-a-2d-matrix": "binary-search",
    "search-a-2d-matrix-ii": "binary-search",
    "koko-eating-bananas": "binary-search",
    "find-peak-element": "binary-search",
    "find-first-and-last-position-of-element-in-sorted-array": "binary-search",
    "first-bad-version": "binary-search",
    "sqrt-x": "binary-search",
    // Heap
    "top-k-frequent-elements": "heap-priority-queue",
    "kth-largest-element-in-an-array": "heap-priority-queue",
    "find-median-from-data-stream": "heap-priority-queue",
    "task-scheduler": "heap-priority-queue",
    "last-stone-weight": "heap-priority-queue",
    "k-closest-points-to-origin": "heap-priority-queue",
    "reorganize-string": "heap-priority-queue",
    "kth-largest-element-in-a-stream": "heap-priority-queue",
    "design-twitter": "heap-priority-queue",
    // Backtracking
    "subsets": "backtracking",
    "subsets-ii": "backtracking",
    "permutations": "backtracking",
    "permutations-ii": "backtracking",
    "combination-sum": "backtracking",
    "combination-sum-ii": "backtracking",
    "combinations": "backtracking",
    "letter-combinations-of-a-phone-number": "backtracking",
    "generate-parentheses": "backtracking",
    "n-queens": "backtracking",
    "palindrome-partitioning": "backtracking",
    "word-search": "backtracking",
    // Graphs
    "number-of-islands": "graphs",
    "max-area-of-island": "graphs",
    "clone-graph": "graphs",
    "pacific-atlantic-water-flow": "graphs",
    "surrounded-regions": "graphs",
    "rotting-oranges": "graphs",
    "flood-fill": "graphs",
    "accounts-merge": "graphs",
    "evaluate-division": "graphs",
    "snakes-and-ladders": "graphs",
    "minimum-genetic-mutation": "graphs",
    "is-graph-bipartite": "graphs",
    "loud-and-rich": "graphs",
    "path-with-maximum-probability": "graphs",
    // DP
    "climbing-stairs": "dynamic-programming",
    "min-cost-climbing-stairs": "dynamic-programming",
    "house-robber": "dynamic-programming",
    "house-robber-ii": "dynamic-programming",
    "coin-change": "dynamic-programming",
    "coin-change-2": "dynamic-programming",
    "coin-change-ii": "dynamic-programming",
    "longest-increasing-subsequence": "dynamic-programming",
    "longest-common-subsequence": "dynamic-programming",
    "word-break": "dynamic-programming",
    "maximum-subarray": "dynamic-programming",
    "maximum-product-subarray": "dynamic-programming",
    "partition-equal-subset-sum": "dynamic-programming",
    "target-sum": "dynamic-programming",
    "decode-ways": "dynamic-programming",
    "unique-paths": "dynamic-programming",
    "edit-distance": "dynamic-programming",
    "jump-game": "dynamic-programming",
    "jump-game-ii": "dynamic-programming",
    "minimum-path-sum": "dynamic-programming",
    "best-time-to-buy-and-sell-stock": "dynamic-programming",
    "best-time-to-buy-and-sell-stock-ii": "dynamic-programming",
    "best-time-to-buy-and-sell-stock-with-cooldown": "dynamic-programming",
    "perfect-squares": "dynamic-programming",
    "range-sum-query-immutable": "dynamic-programming",
    "range-sum-query-2d-immutable": "dynamic-programming",
    // Greedy
    "gas-station": "greedy",
    "partition-labels": "greedy",
    // Tries
    "implement-trie-prefix-tree": "tries",
    "design-add-and-search-words-data-structure": "tries",
    "word-search-ii": "tries",
    // Linked list
    "lru-cache": "linked-list",
    // Arrays & Hashing (explicit)
    "two-sum": "arrays-hashing",
    "contains-duplicate": "arrays-hashing",
    "valid-anagram": "arrays-hashing",
    "group-anagrams": "arrays-hashing",
    "product-of-array-except-self": "arrays-hashing",
    "longest-consecutive-sequence": "arrays-hashing",
    "valid-sudoku": "arrays-hashing",
    "set-matrix-zeroes": "arrays-hashing",
    "spiral-matrix": "arrays-hashing",
    "rotate-image": "arrays-hashing",
    "game-of-life": "arrays-hashing",
    "subarray-sum-equals-k": "arrays-hashing",
    "majority-element": "arrays-hashing",
    "first-missing-positive": "arrays-hashing",
    "ransom-note": "arrays-hashing",
    "longest-common-prefix": "arrays-hashing"
]

// Assign a problem to its primary NeetCode topic.
// Prefers manual overrides, then specific topics, then generic fallback.
func assignTopic(
    for manifestProblem: ManifestProblem?,
    slug: String,
    lcTopicToNeetcode: [String: String]
) -> String {
    // Check manual override first
    if let override = slugOverrides[slug] {
        return override
    }

    guard let problem = manifestProblem else { return "misc" }

    // Pass 1: Look for a specific (non-generic) topic match
    for lcTopic in problem.topics where !genericTopics.contains(lcTopic) {
        if let neetcodeId = lcTopicToNeetcode[lcTopic] {
            return neetcodeId
        }
    }

    // Pass 2: Fall back to generic topics
    for lcTopic in problem.topics where genericTopics.contains(lcTopic) {
        if let neetcodeId = lcTopicToNeetcode[lcTopic] {
            return neetcodeId
        }
    }

    return "misc"
}

// MARK: - Main

enum PartitionError: Error {
    case invalidSolutionsFormat
}

func loadSolutions(from path: String) throws -> [String: ProblemSolution] {
    let solutionsData = try Data(contentsOf: URL(fileURLWithPath: path))
    let rawObject = try JSONSerialization.jsonObject(with: solutionsData)
    guard let rawJSON = rawObject as? [String: Any] else {
        throw PartitionError.invalidSolutionsFormat
    }

    var allSolutions: [String: ProblemSolution] = [:]
    let decoder = JSONDecoder()

    if let solutionsArray = rawJSON["solutions"] as? [[String: Any]] {
        let arrayData = try JSONSerialization.data(withJSONObject: solutionsArray)
        let parsed = try decoder.decode([ProblemSolution].self, from: arrayData)
        for solution in parsed {
            allSolutions[solution.problemSlug] = solution
        }
        print("Loaded \(parsed.count) solutions from array")
    }

    let reservedKeys: Set<String> = ["solutions", "version"]
    let formatter = ISO8601DateFormatter()
    let now = formatter.string(from: Date())
    var slugKeyCount = 0

    for (key, value) in rawJSON where !reservedKeys.contains(key) {
        guard allSolutions[key] == nil else { continue }
        guard let entryDict = value as? [String: Any] else { continue }

        let entryData = try JSONSerialization.data(withJSONObject: entryDict)
        let partial = try decoder.decode(SlugKeyedSolution.self, from: entryData)

        let normalizedApproaches = partial.approaches.enumerated().map { index, raw in
            raw.normalized(index: index)
        }
        let solution = ProblemSolution(
            id: UUID().uuidString.lowercased(),
            problemSlug: key,
            summary: partial.summary,
            approaches: normalizedApproaches,
            relatedProblems: partial.relatedProblems,
            lastUpdated: now
        )
        allSolutions[key] = solution
        slugKeyCount += 1
    }

    print("Loaded \(slugKeyCount) additional solutions from slug keys")
    print("Total unique solutions: \(allSolutions.count)")
    return allSolutions
}

func loadManifest(from path: String) throws -> ProblemManifest {
    let manifestData = try Data(contentsOf: URL(fileURLWithPath: path))
    let decoder = JSONDecoder()
    let manifest = try decoder.decode(ProblemManifest.self, from: manifestData)
    print("Loaded manifest with \(manifest.problems.count) problems")
    return manifest
}

func buildTopicBuckets(
    allSolutions: [String: ProblemSolution],
    slugToManifest: [String: ManifestProblem],
    lcToNeetcode: [String: String]
) -> [String: [ProblemSolution]] {
    var topicBuckets: [String: [ProblemSolution]] = [:]
    for (slug, solution) in allSolutions {
        let manifestProblem = slugToManifest[slug]
        let topicId = assignTopic(for: manifestProblem, slug: slug, lcTopicToNeetcode: lcToNeetcode)
        topicBuckets[topicId, default: []].append(solution)
    }

    for (topicId, solutions) in topicBuckets {
        topicBuckets[topicId] = solutions.sorted { $0.problemSlug < $1.problemSlug }
    }

    return topicBuckets
}

func orderedTopicIds(from topicBuckets: [String: [ProblemSolution]]) -> [String] {
    let baseTopics = neetcodeTopics.map(\.id)
    let misc = topicBuckets.keys.contains("misc") ? ["misc"] : []
    return baseTopics + misc
}

func buildIndexData(
    topicBuckets: [String: [ProblemSolution]],
    slugToManifest: [String: ManifestProblem],
    allTopicIds: [String]
) -> (topics: [SolutionIndexTopic], problemIndex: [String: SolutionIndexEntry]) {
    var indexTopics: [SolutionIndexTopic] = []
    var problemIndex: [String: SolutionIndexEntry] = [:]

    for topicId in allTopicIds {
        guard let solutions = topicBuckets[topicId], !solutions.isEmpty else { continue }

        let topicDef = neetcodeTopics.first { $0.id == topicId }
        let topicName = topicDef?.name ?? "Miscellaneous"
        let fileName = "\(topicId).json"

        var difficulties: [String: Int] = [:]
        for solution in solutions {
            if let mp = slugToManifest[solution.problemSlug] {
                let diff = mp.difficulty.lowercased()
                difficulties[diff, default: 0] += 1
            } else {
                difficulties["unknown", default: 0] += 1
            }
        }

        indexTopics.append(SolutionIndexTopic(
            id: topicId,
            name: topicName,
            file: fileName,
            problemCount: solutions.count,
            difficulties: difficulties
        ))

        for solution in solutions {
            let mp = slugToManifest[solution.problemSlug]
            problemIndex[solution.problemSlug] = SolutionIndexEntry(
                topic: topicId,
                number: mp?.number,
                difficulty: mp?.difficulty.lowercased()
            )
        }
    }

    return (indexTopics, problemIndex)
}

func makeIndexFile(
    totalProblems: Int,
    topics: [SolutionIndexTopic],
    problemIndex: [String: SolutionIndexEntry]
) -> SolutionIndexFile {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.string(from: Date())
    return SolutionIndexFile(
        version: "2.0.0",
        lastUpdated: today,
        totalProblems: totalProblems,
        topics: topics,
        problemIndex: problemIndex
    )
}

func writeIndexFile(_ indexFile: SolutionIndexFile, outputDir: String) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let indexData = try encoder.encode(indexFile)
    let indexPath = outputDir + "/index.json"
    try indexData.write(to: URL(fileURLWithPath: indexPath))
    print("Wrote \(indexPath)")
}

func writeTopicFiles(
    topicBuckets: [String: [ProblemSolution]],
    allTopicIds: [String],
    outputDir: String
) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    for topicId in allTopicIds {
        guard let solutions = topicBuckets[topicId], !solutions.isEmpty else { continue }

        let bundle = TopicSolutionsBundle(
            topic: topicId,
            version: "2.0.0",
            solutions: solutions
        )

        let data = try encoder.encode(bundle)
        let filePath = outputDir + "/\(topicId).json"
        try data.write(to: URL(fileURLWithPath: filePath))
        print("Wrote \(filePath) (\(solutions.count) solutions)")
    }
}

func printSummary(totalSolutions: Int, topics: [SolutionIndexTopic]) {
    print("\n=== Migration Summary ===")
    print("Total solutions: \(totalSolutions)")
    print("Topic files: \(topics.count)")
    for topic in topics {
        print("  \(topic.name): \(topic.problemCount) problems")
    }

    let totalInFiles = topics.reduce(0) { $0 + $1.problemCount }
    assert(totalInFiles == totalSolutions, "Mismatch: \(totalInFiles) in files vs \(totalSolutions) total")
    print("\nVerification passed: \(totalInFiles) solutions across \(topics.count) topic files")
}

func main() throws {
    let baseDir = FileManager.default.currentDirectoryPath
    let solutionsPath = baseDir + "/FocusApp/Resources/Solutions.json"
    let manifestPath = baseDir + "/FocusApp/Resources/problem-manifest.json"
    let outputDir = baseDir + "/FocusApp/Resources/Solutions"

    let allSolutions = try loadSolutions(from: solutionsPath)
    let manifest = try loadManifest(from: manifestPath)
    let slugToManifest = Dictionary(uniqueKeysWithValues: manifest.problems.map { ($0.slug, $0) })

    let lcToNeetcode = buildTopicAssignment()
    let topicBuckets = buildTopicBuckets(
        allSolutions: allSolutions,
        slugToManifest: slugToManifest,
        lcToNeetcode: lcToNeetcode
    )

    let allTopicIds = orderedTopicIds(from: topicBuckets)
    let indexData = buildIndexData(
        topicBuckets: topicBuckets,
        slugToManifest: slugToManifest,
        allTopicIds: allTopicIds
    )
    let indexFile = makeIndexFile(
        totalProblems: allSolutions.count,
        topics: indexData.topics,
        problemIndex: indexData.problemIndex
    )

    try writeIndexFile(indexFile, outputDir: outputDir)
    try writeTopicFiles(topicBuckets: topicBuckets, allTopicIds: allTopicIds, outputDir: outputDir)
    printSummary(totalSolutions: allSolutions.count, topics: indexData.topics)
}

do {
    try main()
} catch {
    fputs("Error: \(error)\n", stderr)
    exit(1)
}
