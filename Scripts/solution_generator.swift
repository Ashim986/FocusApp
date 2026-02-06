#!/usr/bin/env swift

import Foundation

// swiftlint:disable file_length

// MARK: - String Helpers

extension String {
    func leftPadded(toLength length: Int) -> String {
        if count >= length { return self }
        return String(repeating: " ", count: length - count) + self
    }
}

// MARK: - Shared Models (match app schema)

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

struct ProblemSolution: Codable {
    let id: String
    let problemSlug: String
    let summary: String
    let approaches: [SolutionApproach]
    let relatedProblems: [String]?
    let lastUpdated: String
}

struct SolutionsBundle: Codable {
    let version: String
    let solutions: [ProblemSolution]
}

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

// MARK: - Topic Output Models (match TopicSolutionModels.swift)

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

// MARK: - Generator Input/Output

struct GeneratedSolution: Codable {
    let summary: String
    let approaches: [GeneratedApproach]
    let relatedProblems: [String]?
}

struct GeneratedApproach: Codable {
    let name: String
    let intuition: String
    let approach: String
    let explanation: String
    let code: String
    let complexity: ComplexityAnalysis
    let testCases: [GeneratedTestCase]
}

struct GeneratedTestCase: Codable {
    let input: String
    let expectedOutput: String
    let explanation: String?
}

// MARK: - Batch Checkpoint

struct BatchCheckpoint: Codable {
    var startedAt: String
    var lastUpdatedAt: String
    var totalTarget: Int
    var completed: [String: SlugStatus]

    struct SlugStatus: Codable {
        let status: String  // "done", "failed", "skipped"
        let topic: String?
        let error: String?
        let completedAt: String
        let retryCount: Int
    }

    static func fresh(totalTarget: Int) -> BatchCheckpoint {
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        return BatchCheckpoint(
            startedAt: now,
            lastUpdatedAt: now,
            totalTarget: totalTarget,
            completed: [:]
        )
    }

    var doneCount: Int { completed.values.filter { $0.status == "done" }.count }
    var failedCount: Int { completed.values.filter { $0.status == "failed" }.count }
    var skippedCount: Int { completed.values.filter { $0.status == "skipped" }.count }
    var failedSlugs: [String] {
        completed.filter { $0.value.status == "failed" }.map(\.key).sorted()
    }
}

func loadCheckpoint(from path: String) -> BatchCheckpoint? {
    let url = URL(fileURLWithPath: path)
    guard let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(BatchCheckpoint.self, from: data)
}

func saveCheckpoint(_ checkpoint: BatchCheckpoint, to path: String) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let data = try? encoder.encode(checkpoint) else { return }
    try? data.write(to: URL(fileURLWithPath: path))
}

// MARK: - Topic Assignment (from partition_solutions.swift)

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
    TopicDef(id: "tries", name: "Tries", leetCodeTopics: ["Trie"]),
    TopicDef(id: "binary-search", name: "Binary Search", leetCodeTopics: ["Binary Search"]),
    TopicDef(id: "greedy", name: "Greedy", leetCodeTopics: ["Greedy"]),
    TopicDef(id: "linked-list", name: "Linked List", leetCodeTopics: ["Linked List"]),
    TopicDef(id: "intervals", name: "Intervals", leetCodeTopics: ["Line Sweep"]),
    TopicDef(id: "trees", name: "Trees", leetCodeTopics: ["Tree", "Binary Tree", "Binary Search Tree"]),
    TopicDef(id: "heap-priority-queue", name: "Heap / Priority Queue", leetCodeTopics: ["Heap (Priority Queue)"]),
    TopicDef(id: "backtracking", name: "Backtracking", leetCodeTopics: ["Backtracking"]),
    TopicDef(id: "graphs", name: "Graphs", leetCodeTopics: ["Graph", "Depth-First Search", "Breadth-First Search"]),
    TopicDef(id: "dynamic-programming", name: "Dynamic Programming", leetCodeTopics: ["Dynamic Programming"]),
    TopicDef(id: "math-geometry", name: "Math & Geometry", leetCodeTopics: ["Math", "Geometry"]),
    TopicDef(id: "bit-manipulation", name: "Bit Manipulation", leetCodeTopics: ["Bit Manipulation"])
]

let genericTopics: Set<String> = ["Array", "Hash Table", "String", "Depth-First Search", "Breadth-First Search"]

let slugOverrides: [String: String] = [
    "insert-interval": "intervals", "merge-intervals": "intervals", "non-overlapping-intervals": "intervals",
    "meeting-rooms": "intervals", "meeting-rooms-ii": "intervals", "find-all-anagrams-in-a-string": "sliding-window",
    "permutation-in-string": "sliding-window", "longest-repeating-character-replacement": "sliding-window",
    "longest-substring-without-repeating-characters": "sliding-window", "minimum-window-substring": "sliding-window",
    "sliding-window-maximum": "sliding-window", "contains-duplicate-ii": "sliding-window", "3sum": "two-pointers",
    "container-with-most-water": "two-pointers", "trapping-rain-water": "two-pointers", "move-zeroes": "two-pointers",
    "remove-duplicates-from-sorted-array": "two-pointers", "sort-colors": "two-pointers",
    "squares-of-a-sorted-array": "two-pointers", "next-permutation": "two-pointers", "rotate-array": "two-pointers",
    "valid-parentheses": "stack", "evaluate-reverse-polish-notation": "stack", "daily-temperatures": "stack",
    "car-fleet": "stack", "asteroid-collision": "stack", "largest-rectangle-in-histogram": "stack",
    "next-greater-element-i": "stack", "basic-calculator": "stack", "basic-calculator-ii": "stack",
    "decode-string": "stack", "min-stack": "stack", "binary-search": "binary-search",
    "search-in-rotated-sorted-array": "binary-search", "find-minimum-in-rotated-sorted-array": "binary-search",
    "search-a-2d-matrix": "binary-search", "search-a-2d-matrix-ii": "binary-search",
    "koko-eating-bananas": "binary-search", "find-peak-element": "binary-search",
    "find-first-and-last-position-of-element-in-sorted-array": "binary-search", "first-bad-version": "binary-search",
    "sqrt-x": "binary-search", "top-k-frequent-elements": "heap-priority-queue",
    "kth-largest-element-in-an-array": "heap-priority-queue", "find-median-from-data-stream": "heap-priority-queue",
    "task-scheduler": "heap-priority-queue", "last-stone-weight": "heap-priority-queue",
    "k-closest-points-to-origin": "heap-priority-queue", "reorganize-string": "heap-priority-queue",
    "kth-largest-element-in-a-stream": "heap-priority-queue", "design-twitter": "heap-priority-queue",
    "subsets": "backtracking", "subsets-ii": "backtracking", "permutations": "backtracking",
    "permutations-ii": "backtracking", "combination-sum": "backtracking", "combination-sum-ii": "backtracking",
    "combinations": "backtracking", "letter-combinations-of-a-phone-number": "backtracking",
    "generate-parentheses": "backtracking", "n-queens": "backtracking", "palindrome-partitioning": "backtracking",
    "word-search": "backtracking", "number-of-islands": "graphs", "max-area-of-island": "graphs",
    "clone-graph": "graphs", "pacific-atlantic-water-flow": "graphs", "surrounded-regions": "graphs",
    "rotting-oranges": "graphs", "flood-fill": "graphs", "accounts-merge": "graphs", "evaluate-division": "graphs",
    "snakes-and-ladders": "graphs", "minimum-genetic-mutation": "graphs", "is-graph-bipartite": "graphs",
    "loud-and-rich": "graphs", "path-with-maximum-probability": "graphs", "climbing-stairs": "dynamic-programming",
    "min-cost-climbing-stairs": "dynamic-programming", "house-robber": "dynamic-programming",
    "house-robber-ii": "dynamic-programming", "coin-change": "dynamic-programming",
    "coin-change-2": "dynamic-programming", "coin-change-ii": "dynamic-programming",
    "longest-increasing-subsequence": "dynamic-programming", "longest-common-subsequence": "dynamic-programming",
    "word-break": "dynamic-programming", "maximum-subarray": "dynamic-programming",
    "maximum-product-subarray": "dynamic-programming", "partition-equal-subset-sum": "dynamic-programming",
    "target-sum": "dynamic-programming", "decode-ways": "dynamic-programming", "unique-paths": "dynamic-programming",
    "edit-distance": "dynamic-programming", "jump-game": "dynamic-programming", "jump-game-ii": "dynamic-programming",
    "minimum-path-sum": "dynamic-programming", "best-time-to-buy-and-sell-stock": "dynamic-programming",
    "best-time-to-buy-and-sell-stock-ii": "dynamic-programming",
    "best-time-to-buy-and-sell-stock-with-cooldown": "dynamic-programming", "perfect-squares": "dynamic-programming",
    "range-sum-query-immutable": "dynamic-programming", "range-sum-query-2d-immutable": "dynamic-programming",
    "gas-station": "greedy", "partition-labels": "greedy", "implement-trie-prefix-tree": "tries",
    "design-add-and-search-words-data-structure": "tries", "word-search-ii": "tries", "lru-cache": "linked-list",
    "two-sum": "arrays-hashing", "contains-duplicate": "arrays-hashing", "valid-anagram": "arrays-hashing",
    "group-anagrams": "arrays-hashing", "product-of-array-except-self": "arrays-hashing",
    "longest-consecutive-sequence": "arrays-hashing", "valid-sudoku": "arrays-hashing",
    "set-matrix-zeroes": "arrays-hashing", "spiral-matrix": "arrays-hashing", "rotate-image": "arrays-hashing",
    "game-of-life": "arrays-hashing", "subarray-sum-equals-k": "arrays-hashing", "majority-element": "arrays-hashing",
    "first-missing-positive": "arrays-hashing", "ransom-note": "arrays-hashing",
    "longest-common-prefix": "arrays-hashing"
]

func buildTopicLookup() -> [String: String] {
    var mapping: [String: String] = [:]
    for topicDef in neetcodeTopics {
        for lcTopic in topicDef.leetCodeTopics where mapping[lcTopic] == nil {
            mapping[lcTopic] = topicDef.id
        }
    }
    return mapping
}

func assignTopic(
    for problem: ProblemManifest.ProblemManifestEntry?,
    slug: String,
    lcTopicToNeetcode: [String: String]
) -> String {
    if let override = slugOverrides[slug] { return override }
    guard let problem = problem else { return "misc" }
    for lcTopic in problem.topics where !genericTopics.contains(lcTopic) {
        if let neetcodeId = lcTopicToNeetcode[lcTopic] { return neetcodeId }
    }
    for lcTopic in problem.topics where genericTopics.contains(lcTopic) {
        if let neetcodeId = lcTopicToNeetcode[lcTopic] { return neetcodeId }
    }
    return "misc"
}

// MARK: - Provider

protocol SolutionAIProviding {
    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution
}

struct StubSolutionProvider: SolutionAIProviding {
    let stubDirectory: URL

    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution {
        let fileURL = stubDirectory
            .appendingPathComponent(problem.slug)
            .appendingPathExtension("json")
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(GeneratedSolution.self, from: data)
    }
}

struct OpenAISolutionProvider: SolutionAIProviding {
    let apiKey: String
    let model: String
    let baseURL: URL

    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution {
        let prompt = SolutionPromptBuilder.build(for: problem)
        let request = OpenAIRequest(
            model: model,
            messages: [
                .system("You output only valid JSON. No markdown."),
                .user(prompt)
            ],
            responseFormat: .json
        )
        let payload = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            let snippet = body.prefix(200)
            throw GeneratorError.network("OpenAI HTTP \(status): \(snippet)")
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw GeneratorError.invalidResponse("Missing content")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: content)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeneratorError.invalidResponse("JSON encoding failed")
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - Claude Provider

struct ClaudeSolutionProvider: SolutionAIProviding {
    let apiKey: String
    let model: String
    let baseURL: URL

    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution {
        let prompt = SolutionPromptBuilder.build(for: problem)
        let request = ClaudeRequest(
            model: model,
            maxTokens: 4096,
            system: "You output only valid JSON. No markdown fences. No explanation outside the JSON object.",
            messages: [ClaudeMessage(role: "user", content: prompt)]
        )
        let payload = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        urlRequest.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        urlRequest.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw GeneratorError.network("Claude: no HTTP response")
        }

        if http.statusCode == 429 {
            throw GeneratorError.network("Claude: rate limited (429)")
        }
        if http.statusCode == 529 {
            throw GeneratorError.network("Claude: overloaded (529)")
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw GeneratorError.network("Claude HTTP \(http.statusCode): \(body.prefix(200))")
        }

        let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let textBlock = decoded.content.first(where: { $0.type == "text" }),
              let text = textBlock.text else {
            throw GeneratorError.invalidResponse("Claude: no text block in response")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: text)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeneratorError.invalidResponse("Claude: JSON encoding failed")
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - Claude DTOs

struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [ClaudeMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct ClaudeMessage: Encodable {
    let role: String
    let content: String
}

struct ClaudeResponse: Decodable {
    struct ContentBlock: Decodable {
        let type: String
        let text: String?
    }
    let content: [ContentBlock]
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case stopReason = "stop_reason"
    }
}

// MARK: - Gemini Provider

struct GeminiSolutionProvider: SolutionAIProviding {
    let apiKey: String
    let model: String

    func generateSolution(
        for problem: ProblemManifest.ProblemManifestEntry
    ) async throws -> GeneratedSolution {
        let prompt = SolutionPromptBuilder.build(for: problem)
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/"
            + "\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw GeneratorError.invalidArguments("Gemini URL is invalid")
        }

        let systemInstruction = "You output only valid JSON. No markdown fences. " +
            "No explanation outside the JSON object."
        let request = GeminiRequest(
            contents: [GeminiContent(
                parts: [GeminiPart(text: prompt)]
            )],
            systemInstruction: GeminiContent(
                parts: [GeminiPart(text: systemInstruction)]
            ),
            generationConfig: GeminiGenerationConfig(
                responseMimeType: "application/json",
                maxOutputTokens: 8192
            )
        )
        let payload = try JSONEncoder().encode(request)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = payload

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw GeneratorError.network("Gemini: no HTTP response")
        }

        if http.statusCode == 429 {
            throw GeneratorError.network("Gemini: rate limited (429)")
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw GeneratorError.network("Gemini HTTP \(http.statusCode): \(body.prefix(200))")
        }

        let decoded = try JSONDecoder().decode(GeminiResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text else {
            throw GeneratorError.invalidResponse("Gemini: no text in response")
        }

        let jsonString = JSONExtractor.sanitizeJSON(
            JSONExtractor.extractJSONObject(from: text)
        )
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeneratorError.invalidResponse("Gemini: JSON encoding failed")
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - Gemini DTOs

struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiContent
    let generationConfig: GeminiGenerationConfig

    enum CodingKeys: String, CodingKey {
        case contents
        case systemInstruction = "system_instruction"
        case generationConfig = "generation_config"
    }
}

struct GeminiContent: Encodable {
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Encodable {
    let responseMimeType: String
    let maxOutputTokens: Int

    enum CodingKeys: String, CodingKey {
        case responseMimeType = "response_mime_type"
        case maxOutputTokens = "max_output_tokens"
    }
}

struct GeminiResponse: Decodable {
    struct Candidate: Decodable {
        struct Content: Decodable {
            let parts: [GeminiPart]
        }
        let content: Content
    }
    let candidates: [Candidate]?
}

// MARK: - Prompt

enum SolutionPromptBuilder {
    static func build(for problem: ProblemManifest.ProblemManifestEntry) -> String {
        return """
        Generate a LeetCode solution for: \(problem.title) (\(problem.slug), \(problem.difficulty)).
        Topics: \(problem.topics.joined(separator: ", "))

        Return ONLY a JSON object matching this EXACT schema (all values are strings unless noted):
        {
          "summary": "<1-2 sentence string describing the problem and key insight>",
          "approaches": [
            {
              "name": "<string: approach name>",
              "intuition": "<string: why this works>",
              "approach": "<string: step-by-step algorithm>",
              "explanation": "<string: detailed walkthrough>",
              "code": "<string: complete Swift solution>",
              "complexity": {
                "time": "<string: e.g. O(n)>",
                "space": "<string: e.g. O(1)>",
                "timeExplanation": "<string>",
                "spaceExplanation": "<string>"
              },
              "testCases": [
                {
                  "input": "<string: e.g. nums = [2,7,11,15], target = 9>",
                  "expectedOutput": "<string: e.g. [0,1]>",
                  "explanation": "<string>"
                }
              ]
            }
          ],
          "relatedProblems": ["<slug-1>", "<slug-2>"]
        }

        CRITICAL RULES:
        - "summary" MUST be a plain string, NOT an object.
        - Include exactly 2 approaches: one brute-force/baseline, one optimized.
        - "code" must be complete, compilable Swift.
        - Each approach must have at least 2 testCases.
        - "relatedProblems" is an array of slug strings.
        """
    }
}

// MARK: - OpenAI DTOs

struct OpenAIResponseFormat: Encodable {
    let type: String

    static let json = OpenAIResponseFormat(type: "json_object")
}

struct OpenAIRequest: Encodable {
    let model: String
    let messages: [OpenAIMessage]
    let responseFormat: OpenAIResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model, messages
        case responseFormat = "response_format"
    }

    init(model: String, messages: [OpenAIMessage], responseFormat: OpenAIResponseFormat? = nil) {
        self.model = model
        self.messages = messages
        self.responseFormat = responseFormat
    }
}

struct OpenAIMessage: Encodable {
    let role: String
    let content: String

    static func system(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "system", content: content)
    }

    static func user(_ content: String) -> OpenAIMessage {
        OpenAIMessage(role: "user", content: content)
    }
}

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - Helpers

enum JSONExtractor {
    static func extractJSONObject(from content: String) -> String {
        // Strip markdown code fences if present
        var text = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```swift", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}"),
           start <= end {
            text = String(text[start...end])
        }
        return text
    }

    /// Fix unescaped control characters inside JSON string values.
    /// Some LLMs emit real newlines/tabs inside strings instead of \n \t.
    static func sanitizeJSON(_ raw: String) -> String {
        var result = ""
        var inString = false
        var prevChar: Character = " "
        for char in raw {
            if char == "\"" && prevChar != "\\" {
                inString.toggle()
            }
            if inString {
                switch char {
                case "\n": result += "\\n"
                case "\r": result += "\\r"
                case "\t": result += "\\t"
                default: result.append(char)
                }
            } else {
                result.append(char)
            }
            prevChar = char
        }
        return result
    }
}

enum GeneratorError: Error, CustomStringConvertible {
    case invalidArguments(String)
    case invalidResponse(String)
    case validationFailed(String)
    case network(String)

    var description: String {
        switch self {
        case .invalidArguments(let message),
             .invalidResponse(let message),
             .validationFailed(let message),
             .network(let message):
            return message
        }
    }
}

// MARK: - Generation Options

struct GenerationOptions {
    var slugs: [String] = []
    var topic: String?
    var generateAll: Bool
    var outputPath: String
    var replaceExisting: Bool
    var provider: ProviderKind
    var stubDirectory: String?
    var batchMode: Bool = false
    var checkpointPath: String
    var resume: Bool = false
    var delayMs: Int = 1000
    var maxRetries: Int = 2
    var topicOutput: Bool = false
    var targetLimit: Int = 700

    enum ProviderKind: String {
        case stub
        case openai
        case claude
        case gemini
        case groq
        case openrouter
    }
}

// MARK: - Solution Generator

// swiftlint:disable:next type_body_length
struct SolutionGenerator {
    let options: GenerationOptions
    let manifest: ProblemManifest
    let slugToManifest: [String: ProblemManifest.ProblemManifestEntry]
    let lcTopicLookup: [String: String]

    init(options: GenerationOptions, manifest: ProblemManifest) {
        self.options = options
        self.manifest = manifest
        self.slugToManifest = Dictionary(
            uniqueKeysWithValues: manifest.problems.map { ($0.slug, $0) }
        )
        self.lcTopicLookup = buildTopicLookup()
    }

    func run() async throws {
        if options.batchMode {
            try await runBatch()
        } else {
            try await runSingle()
        }
    }

    // MARK: - Single Mode (original behavior)

    private func runSingle() async throws {
        let problems = try selectProblems()
        if problems.isEmpty {
            throw GeneratorError.invalidArguments("No problems matched selection")
        }

        let provider = try makeProvider()
        var generated: [ProblemSolution] = []

        for problem in problems {
            let result = try await provider.generateSolution(for: problem)
            try validate(result, slug: problem.slug)
            generated.append(mapSolution(result, slug: problem.slug))
        }

        if options.topicOutput {
            try writeTopicSolutions(generated)
        } else {
            try writeFlatSolutions(generated)
        }
        print("✓ Generated \(generated.count) solutions")
    }

    // MARK: - Batch Mode

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func runBatch() async throws {
        let problems = try selectProblems()
        if problems.isEmpty {
            throw GeneratorError.invalidArguments("No problems matched selection")
        }

        let provider = try makeProvider()
        var checkpoint = options.resume
            ? (loadCheckpoint(from: options.checkpointPath)
               ?? BatchCheckpoint.fresh(totalTarget: problems.count))
            : BatchCheckpoint.fresh(totalTarget: problems.count)
        checkpoint.totalTarget = problems.count

        // Load existing slugs from topic files to skip already-solved problems
        let existingSlugs = loadExistingSlugs()

        var generated: [ProblemSolution] = []
        var skippedCount = 0
        let total = problems.count
        let formatter = ISO8601DateFormatter()

        print("=== Batch Generation ===")
        print("Target: \(total) problems")
        if options.resume {
            print("Resume: \(checkpoint.doneCount) already completed")
        }
        if !existingSlugs.isEmpty && !options.replaceExisting {
            print("Existing: \(existingSlugs.count) solutions in topic files (skipping)")
        }
        print("")

        for (idx, problem) in problems.enumerated() {
            let current = idx + 1
            let slug = problem.slug

            // Skip if already in checkpoint
            if options.resume,
               let existing = checkpoint.completed[slug],
               existing.status == "done" {
                skippedCount += 1
                continue
            }

            // Skip if already in topic files (unless --replace)
            if !options.replaceExisting && existingSlugs.contains(slug) {
                skippedCount += 1
                continue
            }

            var retryCount = 0
            var succeeded = false

            while retryCount <= options.maxRetries {
                do {
                    let result = try await provider.generateSolution(for: problem)
                    try validate(result, slug: slug)
                    let solution = mapSolution(result, slug: slug)
                    generated.append(solution)

                    let topicId = assignTopic(
                        for: slugToManifest[slug],
                        slug: slug,
                        lcTopicToNeetcode: lcTopicLookup
                    )
                    checkpoint.completed[slug] = BatchCheckpoint.SlugStatus(
                        status: "done",
                        topic: topicId,
                        error: nil,
                        completedAt: formatter.string(from: Date()),
                        retryCount: retryCount
                    )
                    checkpoint.lastUpdatedAt = formatter.string(from: Date())
                    saveCheckpoint(checkpoint, to: options.checkpointPath)

                    // Write to topic file immediately (incremental save)
                    if options.topicOutput {
                        try writeTopicSolutions([solution], silent: true)
                    }

                    print("✓ [\(current)/\(total)] \(slug)")
                    succeeded = true
                    break
                } catch {
                    retryCount += 1
                    if retryCount > options.maxRetries {
                        let topicId = assignTopic(
                            for: slugToManifest[slug],
                            slug: slug,
                            lcTopicToNeetcode: lcTopicLookup
                        )
                        checkpoint.completed[slug] = BatchCheckpoint.SlugStatus(
                            status: "failed",
                            topic: topicId,
                            error: "\(error)",
                            completedAt: formatter.string(from: Date()),
                            retryCount: retryCount - 1
                        )
                        checkpoint.lastUpdatedAt = formatter.string(from: Date())
                        saveCheckpoint(checkpoint, to: options.checkpointPath)
                        print("✗ [\(current)/\(total)] \(slug) — \(error)")
                    } else {
                        let backoffMs = options.delayMs * 2 * retryCount
                        print("⚠ [\(current)/\(total)] \(slug) — retry \(retryCount)/\(options.maxRetries)")
                        try? await Task.sleep(nanoseconds: UInt64(backoffMs) * 1_000_000)
                    }
                }
            }

            if succeeded && idx < problems.count - 1 {
                try? await Task.sleep(nanoseconds: UInt64(options.delayMs) * 1_000_000)
            }
        }

        if !generated.isEmpty {
            if options.topicOutput {
                // Already written incrementally per-problem, just regenerate index
                let baseDir = FileManager.default.currentDirectoryPath
                let solutionsDir = baseDir + "/FocusApp/Resources/Solutions"
                try regenerateIndex(solutionsDir: solutionsDir)
            } else {
                try writeFlatSolutions(generated)
            }
        }

        print("")
        print("=== Batch Complete ===")
        print("Generated: \(generated.count) / \(total)")
        let failedMsg = checkpoint.failedCount > 0
            ? " (\(checkpoint.failedSlugs.joined(separator: ", ")))"
            : ""
        print("Failed:    \(checkpoint.failedCount)\(failedMsg)")
        print("Skipped:   \(skippedCount) (already done)")
        print("Checkpoint: \(options.checkpointPath)")
    }

    // MARK: - Problem Selection

    private func loadExistingSlugs() -> Set<String> {
        let baseDir = FileManager.default.currentDirectoryPath
        let solutionsDir = baseDir + "/FocusApp/Resources/Solutions"
        let decoder = JSONDecoder()
        var slugs = Set<String>()

        let topicIds = neetcodeTopics.map(\.id) + ["misc"]
        for topicId in topicIds {
            let filePath = solutionsDir + "/\(topicId).json"
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
                  let bundle = try? decoder.decode(TopicSolutionsBundle.self, from: data) else {
                continue
            }
            for solution in bundle.solutions {
                // Skip stub solutions — they need to be replaced
                let isStub = solution.approaches.contains { approach in
                    approach.code.contains("TODO: Implement")
                }
                if !isStub {
                    slugs.insert(solution.problemSlug)
                }
            }
        }
        return slugs
    }

    private func selectProblems() throws -> [ProblemManifest.ProblemManifestEntry] {
        let limit = options.targetLimit
        if options.generateAll {
            let sorted = manifest.problems.sorted { $0.number < $1.number }
            return Array(sorted.prefix(limit))
        }
        if !options.slugs.isEmpty {
            return options.slugs.compactMap { slug in
                manifest.problems.first { $0.slug == slug }
            }
        }
        if let topic = options.topic {
            let topicProblems = manifest.problems
                .filter { $0.topics.contains(topic) }
                .sorted { $0.number < $1.number }
            return Array(topicProblems.prefix(limit))
        }
        throw GeneratorError.invalidArguments("Provide --slug, --topic, or --all")
    }

    // MARK: - Provider Factory

    // swiftlint:disable:next cyclomatic_complexity
    private func makeProvider() throws -> SolutionAIProviding {
        switch options.provider {
        case .stub:
            guard let stubDirectory = options.stubDirectory else {
                throw GeneratorError.invalidArguments("--stub-dir is required for stub provider")
            }
            return StubSolutionProvider(stubDirectory: URL(fileURLWithPath: stubDirectory))
        case .openai:
            let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
            if apiKey.isEmpty {
                throw GeneratorError.invalidArguments("OPENAI_API_KEY is required")
            }
            let model = ProcessInfo.processInfo.environment["OPENAI_MODEL"] ?? "gpt-4.1-mini"
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                throw GeneratorError.invalidArguments("OpenAI base URL is invalid")
            }
            return OpenAISolutionProvider(apiKey: apiKey, model: model, baseURL: url)
        case .claude:
            let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? ""
            if apiKey.isEmpty {
                throw GeneratorError.invalidArguments(
                    "ANTHROPIC_API_KEY is required for claude provider"
                )
            }
            let model = ProcessInfo.processInfo.environment["CLAUDE_MODEL"]
                ?? "claude-sonnet-4-20250514"
            guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
                throw GeneratorError.invalidArguments("Anthropic base URL is invalid")
            }
            return ClaudeSolutionProvider(apiKey: apiKey, model: model, baseURL: url)
        case .gemini:
            let apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
            if apiKey.isEmpty {
                throw GeneratorError.invalidArguments(
                    "GEMINI_API_KEY is required (get free at https://aistudio.google.com/apikey)"
                )
            }
            let model = ProcessInfo.processInfo.environment["GEMINI_MODEL"]
                ?? "gemini-2.5-flash"
            return GeminiSolutionProvider(apiKey: apiKey, model: model)
        case .groq:
            let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"] ?? ""
            if apiKey.isEmpty {
                throw GeneratorError.invalidArguments(
                    "GROQ_API_KEY is required (get free at https://console.groq.com)"
                )
            }
            let model = ProcessInfo.processInfo.environment["GROQ_MODEL"]
                ?? "llama-3.3-70b-versatile"
            guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
                throw GeneratorError.invalidArguments("Groq base URL is invalid")
            }
            return OpenAISolutionProvider(apiKey: apiKey, model: model, baseURL: url)
        case .openrouter:
            let apiKey = ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"] ?? ""
            if apiKey.isEmpty {
                throw GeneratorError.invalidArguments(
                    "OPENROUTER_API_KEY is required (get free at https://openrouter.ai)"
                )
            }
            let model = ProcessInfo.processInfo.environment["OPENROUTER_MODEL"]
                ?? "google/gemini-2.0-flash-exp:free"
            guard let url = URL(
                string: "https://openrouter.ai/api/v1/chat/completions"
            ) else {
                throw GeneratorError.invalidArguments("OpenRouter base URL is invalid")
            }
            return OpenAISolutionProvider(apiKey: apiKey, model: model, baseURL: url)
        }
    }

    // MARK: - Mapping

    private func mapSolution(_ generated: GeneratedSolution, slug: String) -> ProblemSolution {
        let formatter = ISO8601DateFormatter()
        let approaches = generated.approaches.enumerated().map { index, item in
            SolutionApproach(
                id: UUID().uuidString.lowercased(),
                name: item.name,
                order: index + 1,
                intuition: item.intuition,
                approach: item.approach,
                explanation: item.explanation,
                code: item.code,
                complexity: item.complexity,
                testCases: item.testCases.map {
                    SolutionTestCase(
                        id: UUID().uuidString.lowercased(),
                        input: $0.input,
                        expectedOutput: $0.expectedOutput,
                        explanation: $0.explanation
                    )
                }
            )
        }

        return ProblemSolution(
            id: UUID().uuidString.lowercased(),
            problemSlug: slug,
            summary: generated.summary,
            approaches: approaches,
            relatedProblems: generated.relatedProblems,
            lastUpdated: formatter.string(from: Date())
        )
    }

    // MARK: - Validation

    private func validate(_ solution: GeneratedSolution, slug: String) throws {
        guard !solution.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeneratorError.validationFailed("\(slug): summary is empty")
        }
        guard solution.approaches.count >= 2 else {
            throw GeneratorError.validationFailed("\(slug): need at least 2 approaches")
        }
        for (index, approach) in solution.approaches.enumerated() {
            if approach.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw GeneratorError.validationFailed("\(slug): approach \(index) missing name")
            }
            if approach.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw GeneratorError.validationFailed("\(slug): approach \(index) missing code")
            }
        }
    }

    // MARK: - Flat File Output (original mode)

    private func writeFlatSolutions(_ newSolutions: [ProblemSolution]) throws {
        let outputURL = URL(fileURLWithPath: options.outputPath)
        let existingData = try? Data(contentsOf: outputURL)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        if let existingData,
           let existingBundle = try? JSONDecoder().decode(SolutionsBundle.self, from: existingData) {
            var merged = existingBundle.solutions
            let existingSlugs = Set(merged.map { $0.problemSlug })

            for solution in newSolutions {
                if existingSlugs.contains(solution.problemSlug) {
                    if options.replaceExisting {
                        merged.removeAll { $0.problemSlug == solution.problemSlug }
                    } else {
                        continue
                    }
                }
                merged.append(solution)
            }

            let bundle = SolutionsBundle(version: existingBundle.version, solutions: merged)
            try encoder.encode(bundle).write(to: outputURL)
            return
        }

        let bundle = SolutionsBundle(version: "1.0.0", solutions: newSolutions)
        try encoder.encode(bundle).write(to: outputURL)
    }

    // MARK: - Topic File Output (--topic-output mode)

    private func writeTopicSolutions(_ newSolutions: [ProblemSolution], silent: Bool = false) throws {
        let baseDir = FileManager.default.currentDirectoryPath
        let solutionsDir = baseDir + "/FocusApp/Resources/Solutions"

        try FileManager.default.createDirectory(
            atPath: solutionsDir,
            withIntermediateDirectories: true
        )

        var topicGroups: [String: [ProblemSolution]] = [:]
        for solution in newSolutions {
            let topicId = assignTopic(
                for: slugToManifest[solution.problemSlug],
                slug: solution.problemSlug,
                lcTopicToNeetcode: lcTopicLookup
            )
            topicGroups[topicId, default: []].append(solution)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let decoder = JSONDecoder()

        for (topicId, solutions) in topicGroups {
            let filePath = solutionsDir + "/\(topicId).json"
            let fileURL = URL(fileURLWithPath: filePath)

            var merged: [ProblemSolution]
            if let existingData = try? Data(contentsOf: fileURL),
               let existing = try? decoder.decode(TopicSolutionsBundle.self, from: existingData) {
                merged = existing.solutions
                let existingSlugs = Set(merged.map { $0.problemSlug })

                for solution in solutions {
                    if existingSlugs.contains(solution.problemSlug) {
                        // Check if the existing solution is a stub
                        let isStub = merged.first(where: { $0.problemSlug == solution.problemSlug })
                            .map { sol in sol.approaches.contains { $0.code.contains("TODO: Implement") } }
                            ?? false

                        if options.replaceExisting || isStub {
                            merged.removeAll { $0.problemSlug == solution.problemSlug }
                        } else {
                            continue
                        }
                    }
                    merged.append(solution)
                }
            } else {
                merged = solutions
            }

            merged.sort { $0.problemSlug < $1.problemSlug }

            let bundle = TopicSolutionsBundle(topic: topicId, version: "2.0.0", solutions: merged)
            try encoder.encode(bundle).write(to: fileURL)
            if !silent {
                print("  Wrote \(topicId).json (\(merged.count) solutions)")
            }
        }

        if !silent {
            try regenerateIndex(solutionsDir: solutionsDir)
        }
    }

    private func regenerateIndex(solutionsDir: String) throws {
        let fm = FileManager.default
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        var indexTopics: [SolutionIndexTopic] = []
        var problemIndex: [String: SolutionIndexEntry] = [:]
        var totalSolutions = 0

        let orderedTopicIds = neetcodeTopics.map(\.id) + ["misc"]

        for topicId in orderedTopicIds {
            let filePath = solutionsDir + "/\(topicId).json"
            guard fm.fileExists(atPath: filePath) else { continue }

            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let bundle = try decoder.decode(TopicSolutionsBundle.self, from: data)
            guard !bundle.solutions.isEmpty else { continue }

            let topicDef = neetcodeTopics.first { $0.id == topicId }
            let topicName = topicDef?.name ?? "Miscellaneous"

            var difficulties: [String: Int] = [:]
            for solution in bundle.solutions {
                if let mp = slugToManifest[solution.problemSlug] {
                    difficulties[mp.difficulty.lowercased(), default: 0] += 1
                } else {
                    difficulties["unknown", default: 0] += 1
                }
            }

            indexTopics.append(SolutionIndexTopic(
                id: topicId,
                name: topicName,
                file: "\(topicId).json",
                problemCount: bundle.solutions.count,
                difficulties: difficulties
            ))

            for solution in bundle.solutions {
                let mp = slugToManifest[solution.problemSlug]
                problemIndex[solution.problemSlug] = SolutionIndexEntry(
                    topic: topicId,
                    number: mp?.number,
                    difficulty: mp?.difficulty.lowercased()
                )
            }

            totalSolutions += bundle.solutions.count
        }

        let today = {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            return fmt.string(from: Date())
        }()

        let indexFile = SolutionIndexFile(
            version: "2.0.0",
            lastUpdated: today,
            totalProblems: totalSolutions,
            topics: indexTopics,
            problemIndex: problemIndex
        )

        try encoder.encode(indexFile).write(to: URL(fileURLWithPath: solutionsDir + "/index.json"))
        print("  Updated index.json (\(totalSolutions) total solutions)")
    }
}

// MARK: - Status Command

func runStatus(manifest: ProblemManifest, targetLimit: Int = 700) {
    let baseDir = FileManager.default.currentDirectoryPath
    let solutionsDir = baseDir + "/FocusApp/Resources/Solutions"

    let decoder = JSONDecoder()
    let lcLookup = buildTopicLookup()

    // Target: top N problems by LeetCode number (Easy + Medium)
    let targetProblems = manifest.problems
        .sorted { $0.number < $1.number }
        .prefix(targetLimit)

    var topicTargets: [String: Int] = [:]
    for problem in targetProblems {
        let topicId = assignTopic(
            for: problem,
            slug: problem.slug,
            lcTopicToNeetcode: lcLookup
        )
        topicTargets[topicId, default: 0] += 1
    }

    var topicDone: [String: Int] = [:]
    var totalDone = 0

    let orderedTopicIds = neetcodeTopics.map(\.id) + ["misc"]
    for topicId in orderedTopicIds {
        let filePath = solutionsDir + "/\(topicId).json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let bundle = try? decoder.decode(TopicSolutionsBundle.self, from: data) else {
            continue
        }
        topicDone[topicId] = bundle.solutions.count
        totalDone += bundle.solutions.count
    }

    let checkpointPath = baseDir + "/Scripts/.batch-checkpoint.json"
    let checkpoint = loadCheckpoint(from: checkpointPath)

    print("=== Solution Coverage (top \(targetProblems.count) problems by number) ===")
    print("")
    let header = "Topic".padding(toLength: 28, withPad: " ", startingAt: 0)
        + "  Done".padding(toLength: 7, withPad: " ", startingAt: 0)
        + "  Target".padding(toLength: 9, withPad: " ", startingAt: 0)
        + "  Coverage"
    print(header)
    print(String(repeating: "─", count: 56))

    for topicId in orderedTopicIds {
        let target = topicTargets[topicId] ?? 0
        guard target > 0 else { continue }
        let done = topicDone[topicId] ?? 0
        let pct = target > 0 ? Double(done) / Double(target) * 100.0 : 0.0
        let topicDef = neetcodeTopics.first { $0.id == topicId }
        let name = topicDef?.name ?? "Miscellaneous"
        let doneStr = "\(done)".leftPadded(toLength: 6)
        let targetStr = "\(target)".leftPadded(toLength: 8)
        let pctStr = String(format: "%.1f%%", pct).leftPadded(toLength: 10)
        print("\(name.padding(toLength: 28, withPad: " ", startingAt: 0)) \(doneStr) \(targetStr) \(pctStr)")
    }

    print(String(repeating: "─", count: 56))
    let totalTarget = targetProblems.count
    let totalPct = totalTarget > 0 ? Double(totalDone) / Double(totalTarget) * 100.0 : 0.0
    let totalDoneStr = "\(totalDone)".leftPadded(toLength: 6)
    let totalTargetStr = "\(totalTarget)".leftPadded(toLength: 8)
    let totalPctStr = String(format: "%.1f%%", totalPct).leftPadded(toLength: 10)
    let totalLabel = "TOTAL".padding(toLength: 28, withPad: " ", startingAt: 0)
    print("\(totalLabel) \(totalDoneStr) \(totalTargetStr) \(totalPctStr)")

    if let checkpoint = checkpoint {
        print("")
        print("Checkpoint: \(checkpoint.doneCount) done, \(checkpoint.failedCount) failed")
        if !checkpoint.failedSlugs.isEmpty {
            print("Failed: \(checkpoint.failedSlugs.joined(separator: ", "))")
        }
    }
}

// MARK: - CLI

func runCLI() async {
    let args = Array(CommandLine.arguments.dropFirst())

    if let command = args.first, command == "status" {
        do {
            let manifest = try loadManifest()
            var limit = 700
            if let limitIdx = args.firstIndex(of: "--limit"),
               limitIdx + 1 < args.count,
               let parsed = Int(args[limitIdx + 1]) {
                limit = parsed
            }
            runStatus(manifest: manifest, targetLimit: limit)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
        return
    }

    do {
        let options = try parseArguments()
        let manifest = try loadManifest()
        let generator = SolutionGenerator(options: options, manifest: manifest)
        try await generator.run()
    } catch {
        fputs("Error: \(error)\n", stderr)
        printUsage()
        exit(1)
    }
}

// Entry point
let semaphore = DispatchSemaphore(value: 0)
Task {
    await runCLI()
    semaphore.signal()
}
semaphore.wait()

func loadManifest() throws -> ProblemManifest {
    let path = FileManager.default.currentDirectoryPath +
        "/FocusApp/Resources/problem-manifest.json"
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(ProblemManifest.self, from: data)
}

func parseArguments() throws -> GenerationOptions {
    let baseDir = FileManager.default.currentDirectoryPath
    var options = GenerationOptions(
        generateAll: false,
        outputPath: baseDir + "/FocusApp/Resources/Solutions.json",
        replaceExisting: false,
        provider: .stub,
        stubDirectory: nil,
        checkpointPath: baseDir + "/Scripts/.batch-checkpoint.json"
    )

    var args = Array(CommandLine.arguments.dropFirst())
    guard !args.isEmpty, args.removeFirst() == "generate" else {
        throw GeneratorError.invalidArguments("Expected 'generate' or 'status' command")
    }

    var index = 0
    func requireValue(for flag: String) throws -> String {
        guard index < args.count else {
            throw GeneratorError.invalidArguments("Missing value for \(flag)")
        }
        let value = args[index]
        index += 1
        return value
    }
    func requireInt(for flag: String) throws -> Int {
        let value = try requireValue(for: flag)
        guard let intValue = Int(value) else {
            throw GeneratorError.invalidArguments("Invalid \(flag) value")
        }
        return intValue
    }

    let handlers: [String: () throws -> Void] = [
        "--slug": { options.slugs.append(try requireValue(for: "--slug")) },
        "--all": { options.generateAll = true },
        "--topic": { options.topic = try requireValue(for: "--topic") },
        "--output": { options.outputPath = try requireValue(for: "--output") },
        "--replace": { options.replaceExisting = true },
        "--provider": {
            let raw = try requireValue(for: "--provider")
            guard let provider = GenerationOptions.ProviderKind(rawValue: raw) else {
                throw GeneratorError.invalidArguments("Invalid --provider value")
            }
            options.provider = provider
        },
        "--stub-dir": { options.stubDirectory = try requireValue(for: "--stub-dir") },
        "--batch": { options.batchMode = true },
        "--checkpoint": { options.checkpointPath = try requireValue(for: "--checkpoint") },
        "--resume": {
            options.resume = true
            options.batchMode = true
        },
        "--delay": { options.delayMs = try requireInt(for: "--delay") },
        "--max-retries": { options.maxRetries = try requireInt(for: "--max-retries") },
        "--topic-output": { options.topicOutput = true },
        "--limit": { options.targetLimit = try requireInt(for: "--limit") }
    ]

    while index < args.count {
        let arg = args[index]
        index += 1
        if let handler = handlers[arg] {
            try handler()
        }
    }

    return options
}

func printUsage() {
    let usage = "Usage:\n  solution_generator.swift generate [options]\n  solution_generator.swift status\n\n" +
        "Commands:\n  generate              Generate solutions for selected problems\n" +
        "  status                Show solution coverage by topic\n\n" +
        "Generate Options:\n  --slug <slug>         Generate for a specific slug (repeatable)\n" +
        "  --all                 Generate for all problems in the manifest\n" +
        "  --topic <topic>       Generate for all problems with a topic\n" +
        "  --output <path>       Output Solutions.json path\n" +
        "  --provider <provider>  AI provider (stub|openai|claude|gemini|groq|openrouter)\n" +
        "  --stub-dir <path>     Directory of stub JSON files (<slug>.json)\n" +
        "  --replace             Replace existing solutions if slug exists\n\n" +
        "Batch Options:\n  --batch               Enable batch mode (per-problem error handling + checkpoint)\n" +
        "  --checkpoint <path>   Checkpoint file path (default: Scripts/.batch-checkpoint.json)\n" +
        "  --resume              Resume from existing checkpoint (implies --batch)\n" +
        "  --delay <ms>          Delay between API calls in milliseconds (default: 1000)\n" +
        "  --max-retries <n>     Max retries per failed problem (default: 2)\n" +
        "  --topic-output        Write directly to Solutions/<topic>.json files\n" +
        "  --limit <n>           Max problems to target, sorted by number (default: 700)\n\n" +
        "Providers (★ = free tier available):\n" +
        "  stub         Local JSON files (no API)\n" +
        "  openai       OpenAI API (OPENAI_API_KEY, model: OPENAI_MODEL)\n" +
        "  claude       Anthropic API (ANTHROPIC_API_KEY, model: CLAUDE_MODEL)\n" +
        "  gemini  ★    Google Gemini (GEMINI_API_KEY, model: GEMINI_MODEL)\n" +
        "  groq    ★    Groq (GROQ_API_KEY, model: GROQ_MODEL)\n" +
        "  openrouter ★ OpenRouter (OPENROUTER_API_KEY, model: OPENROUTER_MODEL)\n\n" +
        "Free API keys:\n" +
        "  Gemini:     https://aistudio.google.com/apikey\n" +
        "  Groq:       https://console.groq.com\n" +
        "  OpenRouter:  https://openrouter.ai/keys\n\n" +
        "Examples:\n  # Single problem with stub\n" +
        "  ./solution_generator.swift generate --slug two-sum --provider stub --stub-dir ./stubs\n\n" +
        "  # Batch with Gemini (free)\n" +
        "  GEMINI_API_KEY=... ./solution_generator.swift generate \\\n" +
        "    --all --provider gemini --batch --topic-output --replace --delay 4000\n\n" +
        "  # Batch with Groq (free, fast)\n" +
        "  GROQ_API_KEY=... ./solution_generator.swift generate \\\n" +
        "    --all --provider groq --batch --topic-output --replace --delay 1000\n\n" +
        "  # Batch with Claude\n" +
        "  ANTHROPIC_API_KEY=... ./solution_generator.swift generate \\\n" +
        "    --all --provider claude --batch --topic-output --replace --delay 2000\n\n" +
        "  # Resume interrupted batch\n" +
        "  ./solution_generator.swift generate --all --provider gemini --resume --topic-output\n\n" +
        "  # Check coverage\n  ./solution_generator.swift status"
    print(usage)
}
