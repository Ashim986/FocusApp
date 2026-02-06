#!/usr/bin/env swift

import Foundation

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
            ]
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
            throw GeneratorError.network("OpenAI HTTP \(status)")
        }

        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw GeneratorError.invalidResponse("Missing content")
        }

        let jsonString = JSONExtractor.extractJSONObject(from: content)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw GeneratorError.invalidResponse("JSON encoding failed")
        }

        return try JSONDecoder().decode(GeneratedSolution.self, from: jsonData)
    }
}

// MARK: - Prompt

enum SolutionPromptBuilder {
    static func build(for problem: ProblemManifest.ProblemManifestEntry) -> String {
        return """
        Generate a LeetCode solution JSON for this problem.

        Problem:
        - Title: \(problem.title)
        - Slug: \(problem.slug)
        - Difficulty: \(problem.difficulty)
        - Topics: \(problem.topics.joined(separator: ", "))

        Requirements:
        - Provide EXACT JSON with fields: summary, approaches, relatedProblems.
        - approaches must include TWO approaches:
          1) Baseline (clear but less optimal)
          2) Optimized (best known time/space)
        - Each approach must include: name, intuition, approach, explanation, code, complexity, testCases.
        - complexity must include time, space, timeExplanation, spaceExplanation.
        - testCases must include input, expectedOutput, explanation.
        - Provide Swift code only.
        """
    }
}

// MARK: - OpenAI DTOs

struct OpenAIRequest: Encodable {
    let model: String
    let messages: [OpenAIMessage]
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
        if let start = content.firstIndex(of: "{"),
           let end = content.lastIndex(of: "}"),
           start <= end {
            return String(content[start...end])
        }
        return content
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

// MARK: - Generation

struct GenerationOptions {
    var slugs: [String] = []
    var topic: String?
    var outputPath: String
    var replaceExisting: Bool
    var provider: ProviderKind
    var stubDirectory: String?

    enum ProviderKind: String {
        case stub
        case openai
    }
}

struct SolutionGenerator {
    let options: GenerationOptions
    let manifest: ProblemManifest

    func run() async throws {
        let problems = try selectProblems()
        if problems.isEmpty {
            throw GeneratorError.invalidArguments("No problems matched selection")
        }

        let provider = try makeProvider()
        var generated: [ProblemSolution] = []

        for problem in problems {
            let result = try await provider.generateSolution(for: problem)
            try validate(result, slug: problem.slug)
            generated.append(map(result, slug: problem.slug))
        }

        try writeSolutions(generated)
        print("✓ Generated \(generated.count) solutions")
    }

    private func selectProblems() throws -> [ProblemManifest.ProblemManifestEntry] {
        if !options.slugs.isEmpty {
            return options.slugs.compactMap { slug in
                manifest.problems.first { $0.slug == slug }
            }
        }
        if let topic = options.topic {
            return manifest.problems.filter { $0.topics.contains(topic) }
        }
        throw GeneratorError.invalidArguments("Provide --slug or --topic")
    }

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
            guard let baseURL = URL(string: "https://api.openai.com/v1/chat/completions") else {
                throw GeneratorError.invalidArguments("OpenAI base URL is invalid")
            }
            return OpenAISolutionProvider(apiKey: apiKey, model: model, baseURL: baseURL)
        }
    }

    private func map(_ generated: GeneratedSolution, slug: String) -> ProblemSolution {
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

    private func validate(_ solution: GeneratedSolution, slug: String) throws {
        guard !solution.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeneratorError.validationFailed("\(slug): summary is empty")
        }
        guard solution.approaches.count >= 2 else {
            throw GeneratorError.validationFailed("\(slug): need at least 2 approaches")
        }
        for (index, approach) in solution.approaches.enumerated() {
            let title = approach.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if title.isEmpty {
                throw GeneratorError.validationFailed("\(slug): approach \(index) missing name")
            }
            if approach.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw GeneratorError.validationFailed("\(slug): approach \(index) missing code")
            }
        }
    }

    private func writeSolutions(_ newSolutions: [ProblemSolution]) throws {
        let outputURL = URL(fileURLWithPath: options.outputPath)
        let existingData = try? Data(contentsOf: outputURL)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        if let existingData, let existingBundle = try? JSONDecoder().decode(
            SolutionsBundle.self,
            from: existingData
        ) {
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
            let data = try encoder.encode(bundle)
            try data.write(to: outputURL)
            return
        }

        let bundle = SolutionsBundle(version: "1.0.0", solutions: newSolutions)
        let data = try encoder.encode(bundle)
        try data.write(to: outputURL)
    }
}

// MARK: - CLI

@main
struct SolutionGeneratorCLI {
    static func main() async {
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
}

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
    var options = GenerationOptions(
        outputPath: FileManager.default.currentDirectoryPath +
            "/FocusApp/Resources/Solutions.json",
        replaceExisting: false,
        provider: .stub,
        stubDirectory: nil
    )

    var iterator = CommandLine.arguments.dropFirst().makeIterator()
    guard let command = iterator.next(), command == "generate" else {
        throw GeneratorError.invalidArguments("Expected 'generate' command")
    }

    while let arg = iterator.next() {
        try applyArgument(arg, iterator: &iterator, options: &options)
    }

    return options
}

func applyArgument(
    _ arg: String,
    iterator: inout IndexingIterator<[String]>,
    options: inout GenerationOptions
) throws {
    switch arg {
    case "--slug":
        if let slug = iterator.next() {
            options.slugs.append(slug)
        }
    case "--topic":
        options.topic = iterator.next()
    case "--output":
        if let path = iterator.next() {
            options.outputPath = path
        }
    case "--replace":
        options.replaceExisting = true
    case "--provider":
        guard let value = iterator.next(),
              let provider = GenerationOptions.ProviderKind(rawValue: value) else {
            throw GeneratorError.invalidArguments("Invalid --provider value")
        }
        options.provider = provider
    case "--stub-dir":
        options.stubDirectory = iterator.next()
    default:
        break
    }
}

func printUsage() {
    print("""
    Usage:
      solution_generator.swift generate [options]

    Options:
      --slug <slug>         Generate for a specific slug (repeatable)
      --topic <topic>       Generate for all problems with a topic
      --output <path>       Output Solutions.json path
      --provider <stub|openai>
      --stub-dir <path>     Directory of stub JSON files (<slug>.json)
      --replace             Replace existing solutions if slug exists

    Example:
      ./solution_generator.swift generate --slug two-sum --provider stub --stub-dir ./stubs
    """)
}
