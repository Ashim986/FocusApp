#!/usr/bin/env swift

import Foundation

// MARK: - Solution Models (matching the app's SolutionModels.swift)

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

// MARK: - Solution Template Generator

func generateSolutionTemplate(
    slug: String,
    title: String,
    difficulty: String,
    topics: [String]
) -> ProblemSolution {
    let uuid = UUID().uuidString.lowercased()
    let approachId = UUID().uuidString.lowercased()
    let testId = UUID().uuidString.lowercased()
    let pascalName = slug
        .replacingOccurrences(of: "-", with: " ")
        .capitalized
        .replacingOccurrences(of: " ", with: "")
    let swiftFunctionName = pascalName.prefix(1).lowercased() + pascalName.dropFirst()

    return ProblemSolution(
        id: uuid,
        problemSlug: slug,
        summary: "TODO: Add 1-2 sentence summary of the problem and key insight",
        approaches: [
            SolutionApproach(
                id: approachId,
                name: "TODO: Approach Name (e.g., Two Pointers, DFS, " +
                    "Dynamic Programming)",
                order: 1,
                intuition: "TODO: Explain the key insight that leads to the solution. " +
                    "What pattern does this problem follow? Why does this approach work?",
                approach: "TODO: Step-by-step algorithm:\n1. \n2. \n3. ",
                explanation: "TODO: Detailed explanation of why the solution works. " +
                    "Include any edge cases or tricky parts.",
                code: """
                // TODO: Add Swift solution code
                func \(swiftFunctionName)() {
                    // Implementation
                }
                """,
                complexity: ComplexityAnalysis(
                    time: "O(?)",
                    space: "O(?)",
                    timeExplanation: "TODO: Explain time complexity",
                    spaceExplanation: "TODO: Explain space complexity"
                ),
                testCases: [
                    SolutionTestCase(
                        id: testId,
                        input: "TODO: Example input",
                        expectedOutput: "TODO: Expected output",
                        explanation: "TODO: Explain the test case"
                    )
                ]
            )
        ],
        relatedProblems: nil,
        lastUpdated: ISO8601DateFormatter().string(from: Date())
    )
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

// MARK: - Main

func printUsage() {
    print("""
    Usage: generate_solution.swift <command> [options]

    Commands:
      template <slug>     Generate a solution template for a problem
      batch <topic>       Generate templates for all problems in a topic
      list-topics         List all available topics
      list-problems       List problems (optionally filter by topic)

    Examples:
      ./generate_solution.swift template two-sum
      ./generate_solution.swift batch "Linked List"
      ./generate_solution.swift list-topics
      ./generate_solution.swift list-problems --topic "Array"
    """)
}

func loadManifest() throws -> ProblemManifest {
    let path = FileManager.default.currentDirectoryPath + "/FocusApp/Resources/problem-manifest.json"
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(ProblemManifest.self, from: data)
}

func generateTemplate(slug: String) {
    do {
        let manifest = try loadManifest()
        guard let problem = manifest.problems.first(where: { $0.slug == slug }) else {
            print("Error: Problem '\(slug)' not found in manifest")
            exit(1)
        }

        let template = generateSolutionTemplate(
            slug: problem.slug,
            title: problem.title,
            difficulty: problem.difficulty,
            topics: problem.topics
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(template)

        if let json = String(data: data, encoding: .utf8) {
            print("// Solution template for: \(problem.title) (#\(problem.number))")
            print("// Difficulty: \(problem.difficulty)")
            print("// Topics: \(problem.topics.joined(separator: ", "))")
            print("// Acceptance Rate: \(String(format: "%.1f", problem.acceptanceRate))%")
            print("")
            print(json)
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

func listTopics() {
    do {
        let manifest = try loadManifest()
        var topicCounts: [String: Int] = [:]

        for problem in manifest.problems {
            for topic in problem.topics {
                topicCounts[topic, default: 0] += 1
            }
        }

        print("=== Available Topics ===\n")
        for (topic, count) in topicCounts.sorted(by: { $0.value > $1.value }) {
            print("  \(topic): \(count) problems")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

func listProblems(topic: String?) {
    do {
        let manifest = try loadManifest()
        var problems = manifest.problems

        if let topic = topic {
            problems = problems.filter { $0.topics.contains(topic) }
        }

        print("=== Problems (\(problems.count) total) ===\n")
        for problem in problems.prefix(50) {
            print("#\(problem.number) \(problem.title)")
            print("   Slug: \(problem.slug)")
            print("   Difficulty: \(problem.difficulty)")
            print("   Topics: \(problem.topics.joined(separator: ", "))")
            print("")
        }

        if problems.count > 50 {
            print("... and \(problems.count - 50) more")
        }
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

func batchGenerateForTopic(topic: String) {
    do {
        let manifest = try loadManifest()
        let problems = manifest.problems.filter { $0.topics.contains(topic) }

        if problems.isEmpty {
            print("Error: No problems found for topic '\(topic)'")
            exit(1)
        }

        print("Found \(problems.count) problems for topic: \(topic)")
        print("")

        var solutions: [ProblemSolution] = []

        for problem in problems {
            let template = generateSolutionTemplate(
                slug: problem.slug,
                title: problem.title,
                difficulty: problem.difficulty,
                topics: problem.topics
            )
            solutions.append(template)
        }

        let bundle = SolutionsBundle(version: "1.0.0", solutions: solutions)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(bundle)

        let filename = topic.lowercased().replacingOccurrences(of: " ", with: "-") + "-solutions-template.json"
        let outputPath = FileManager.default.currentDirectoryPath + "/" + filename
        try data.write(to: URL(fileURLWithPath: outputPath))

        print("✓ Generated templates for \(solutions.count) problems")
        print("✓ Saved to: \(outputPath)")
    } catch {
        print("Error: \(error.localizedDescription)")
        exit(1)
    }
}

// MARK: - CLI Parsing

let args = Array(CommandLine.arguments.dropFirst())

guard !args.isEmpty else {
    printUsage()
    exit(0)
}

switch args[0] {
case "template":
    guard args.count > 1 else {
        print("Error: Please provide a problem slug")
        exit(1)
    }
    generateTemplate(slug: args[1])

case "batch":
    guard args.count > 1 else {
        print("Error: Please provide a topic name")
        exit(1)
    }
    batchGenerateForTopic(topic: args.dropFirst().joined(separator: " "))

case "list-topics":
    listTopics()

case "list-problems":
    let topicIndex = args.firstIndex(of: "--topic")
    let topic = topicIndex.map { args[args.index(after: $0)] }
    listProblems(topic: topic)

default:
    print("Unknown command: \(args[0])")
    printUsage()
    exit(1)
}
