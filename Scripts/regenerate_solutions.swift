#!/usr/bin/env swift

// regenerate_solutions.swift
//
// Finds bundled solutions that fail to compile when wrapped by
// LeetCodeExecutionWrapper, then uses the Groq API to regenerate
// correct Swift code.
//
// Usage:
//   export GROQ_API_KEY="gsk_..."
//   swift Scripts/regenerate_solutions.swift [topic-id]
//
// If topic-id is provided, only that topic is processed.
// Otherwise all topics are processed.

import Foundation

// MARK: - Configuration

let solutionsDir = "FocusApp/Resources/Solutions"
let groqModel = "llama-3.3-70b-versatile"
let groqEndpoint = "https://api.groq.com/openai/v1/chat/completions"

// MARK: - Resolve paths

let scriptPath = CommandLine.arguments[0]
let scriptURL = URL(fileURLWithPath: scriptPath).standardized
var candidateURL = scriptURL.deletingLastPathComponent()
for _ in 0..<5 {
    if FileManager.default.fileExists(
        atPath: candidateURL.appendingPathComponent("FocusApp.xcodeproj").path
    ) { break }
    candidateURL = candidateURL.deletingLastPathComponent()
}
let projectRoot = candidateURL.path
let solutionsDirPath = (projectRoot as NSString).appendingPathComponent(solutionsDir)

// MARK: - API Key

guard let apiKey = ProcessInfo.processInfo.environment["GROQ_API_KEY"],
      !apiKey.isEmpty else {
    print("ERROR: GROQ_API_KEY environment variable not set")
    print("Usage: export GROQ_API_KEY=\"gsk_...\" && swift Scripts/regenerate_solutions.swift")
    exit(1)
}

// MARK: - Helpers

func ensureClassSolution(_ code: String) -> String {
    if code.contains("class Solution") || code.contains("struct Solution") {
        return code
    }
    let lines = code.components(separatedBy: "\n")
    var imports: [String] = []
    var bodyLines: [String] = []
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("import ") {
            imports.append(trimmed)
        } else {
            bodyLines.append(line)
        }
    }
    let body = bodyLines.joined(separator: "\n")
        .trimmingCharacters(in: .whitespacesAndNewlines)
    let prefix = imports.isEmpty ? "" : imports.joined(separator: "\n") + "\n\n"
    return "\(prefix)class Solution {\n\(body)\n}"
}

func extractFuncSignature(_ code: String) -> String? {
    let pattern = "func\\s+\\w+\\s*\\([^)]*\\)\\s*(?:->\\s*[^{\\n]+)?"
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(
              in: code, range: NSRange(location: 0, length: (code as NSString).length)
          ) else { return nil }
    return (code as NSString).substring(with: match.range)
}

struct CompileResult {
    let success: Bool
    let stderr: String
}

func compileSwift(_ code: String) -> CompileResult {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("regen_\(UUID().uuidString)")
    try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDir) }

    let sourceFile = tempDir.appendingPathComponent("solution.swift")
    let binaryFile = tempDir.appendingPathComponent("solution")
    try? code.write(to: sourceFile, atomically: true, encoding: .utf8)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
    process.arguments = ["-O", "-o", binaryFile.path, sourceFile.path]
    let stderrPipe = Pipe()
    process.standardError = stderrPipe
    process.standardOutput = Pipe()

    do { try process.run() } catch {
        return CompileResult(success: false, stderr: "Failed to launch swiftc: \(error)")
    }

    let deadline = Date().addingTimeInterval(30)
    while process.isRunning, Date() < deadline {
        Thread.sleep(forTimeInterval: 0.1)
    }
    if process.isRunning { process.terminate() }

    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
    let stderr = String(data: stderrData, encoding: .utf8) ?? ""
    return CompileResult(success: process.terminationStatus == 0, stderr: stderr)
}

// MARK: - Wrapper simulation (minimal)

/// Wraps code similar to how LeetCodeExecutionWrapper does for compilation check.
/// This is a simplified version — we just need to verify compilation.
func wrapForCompilation(_ code: String) -> String {
    let classCode = ensureClassSolution(code)

    guard extractFuncSignature(classCode) != nil else {
        return classCode
    }

    // Check if we need support types
    let needsListNode = classCode.contains("ListNode")
    let needsTreeNode = classCode.contains("TreeNode")

    var parts: [String] = []
    parts.append("import Foundation")
    parts.append("")

    if needsListNode {
        parts.append("""
        class ListNode {
            var val: Int
            var next: ListNode?
            init() { self.val = 0; self.next = nil }
            init(_ val: Int) { self.val = val; self.next = nil }
            init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next }
        }
        """)
    }
    if needsTreeNode {
        parts.append("""
        class TreeNode {
            var val: Int
            var left: TreeNode?
            var right: TreeNode?
            init() { self.val = 0; self.left = nil; self.right = nil }
            init(_ val: Int) { self.val = val; self.left = nil; self.right = nil }
            init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
                self.val = val; self.left = left; self.right = right
            }
        }
        """)
    }

    parts.append(classCode)
    parts.append("")
    parts.append("// Minimal main to verify compilation")
    parts.append("let _ = Solution()")
    return parts.joined(separator: "\n")
}

// MARK: - Groq API

struct GroqMessage: Codable {
    let role: String
    let content: String
}

struct GroqRequest: Codable {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

struct GroqChoice: Codable {
    let message: GroqMessage
}

struct GroqResponse: Codable {
    let choices: [GroqChoice]?
    let error: GroqError?
}

struct GroqError: Codable {
    let message: String
}

func callGroq(prompt: String, retries: Int = 2) -> String? {
    let request = GroqRequest(
        model: groqModel,
        messages: [
            GroqMessage(
                role: "system",
                content: """
                You are a Swift programming expert. You write clean, correct, \
                compilable Swift code for LeetCode problems. \
                Always use proper multi-line formatting with 4-space indentation. \
                Never use semicolons as statement separators. \
                Never put import statements inside a class body. \
                Never subscript String with Int (use String.Index). \
                Always ensure parameters marked as `let` are copied to `var` before mutation. \
                Return ONLY the Swift code, no explanations or markdown.
                """
            ),
            GroqMessage(role: "user", content: prompt)
        ],
        temperature: 0.1,
        maxTokens: 4096
    )

    guard let body = try? JSONEncoder().encode(request) else { return nil }

    guard let endpointURL = URL(string: groqEndpoint) else {
        print("ERROR: Invalid GROQ endpoint URL: \(groqEndpoint)")
        return nil
    }

    var urlRequest = URLRequest(url: endpointURL)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    urlRequest.httpBody = body
    urlRequest.timeoutInterval = 60

    for attempt in 0...retries {
        if attempt > 0 {
            print("    Retrying (attempt \(attempt + 1))...")
            Thread.sleep(forTimeInterval: Double(attempt) * 3.0)
        }

        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?

        let task = URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
            responseData = data
            semaphore.signal()
        }
        task.resume()
        _ = semaphore.wait(timeout: .now() + 90)

        guard let data = responseData,
              let response = try? JSONDecoder().decode(GroqResponse.self, from: data) else {
            continue
        }

        if let error = response.error {
            print("    Groq API error: \(error.message)")
            if error.message.contains("rate_limit") { continue }
            return nil
        }

        if let content = response.choices?.first?.message.content {
            return extractCode(from: content)
        }
    }
    return nil
}

func extractCode(from response: String) -> String {
    // Strip markdown code fences if present
    var code = response
    if code.contains("```swift") {
        let parts = code.components(separatedBy: "```swift")
        if parts.count > 1 {
            code = parts[1].components(separatedBy: "```").first ?? code
        }
    } else if code.contains("```") {
        let parts = code.components(separatedBy: "```")
        if parts.count >= 3 {
            code = parts[1]
        }
    }
    return code.trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Solution processing

struct SolutionIndex: Codable {
    let topics: [TopicEntry]
    struct TopicEntry: Codable {
        let id: String
        let file: String
    }
}

func loadIndex() throws -> SolutionIndex {
    let indexPath = (solutionsDirPath as NSString).appendingPathComponent("index.json")
    let data = try Data(contentsOf: URL(fileURLWithPath: indexPath))
    return try JSONDecoder().decode(SolutionIndex.self, from: data)
}

// Class-design slugs to skip
let classDesignSlugs: Set<String> = [
    "design-add-and-search-words-data-structure", "implement-trie-prefix-tree",
    "word-search-ii", "min-stack", "lru-cache", "lfu-cache",
    "insert-delete-getrandom-o1", "design-twitter",
    "kth-largest-element-in-a-stream", "find-median-from-data-stream",
    "implement-queue-using-stacks", "implement-stack-using-queues",
    "flatten-nested-list-iterator", "peeking-iterator",
    "binary-search-tree-iterator", "online-stock-span",
    "design-circular-queue", "map-sum-pairs", "implement-magic-dictionary",
    "time-based-key-value-store", "my-calendar-i", "my-calendar-ii",
    "range-sum-query-mutable", "online-election",
    "encode-and-decode-tinyurl", "rle-iterator",
    "first-bad-version", "guess-number-higher-or-lower",
    "detect-squares", "serialize-and-deserialize-binary-tree",
    "codec", "design-hashmap", "design-hashset"
]

struct TopicProcessResult {
    var fixed: Int
    var failed: Int
    var skipped: Int

    init(fixed: Int = 0, failed: Int = 0, skipped: Int = 0) {
        self.fixed = fixed
        self.failed = failed
        self.skipped = skipped
    }

    mutating func add(_ other: TopicProcessResult) {
        fixed += other.fixed
        failed += other.failed
        skipped += other.skipped
    }
}

struct TopicFileContents {
    var json: [String: Any]
    var solutions: [[String: Any]]
}

struct ProcessApproachesResult {
    var approaches: [[String: Any]]
    var counts: TopicProcessResult
    var modified: Bool
}

struct ProcessApproachResult {
    var counts: TopicProcessResult
    var modified: Bool
}

func topicFileURL(for topicEntry: SolutionIndex.TopicEntry) -> URL {
    let topicPath = (solutionsDirPath as NSString).appendingPathComponent(topicEntry.file)
    return URL(fileURLWithPath: topicPath)
}

func loadTopicFileContents(from url: URL) throws -> TopicFileContents? {
    let data = try Data(contentsOf: url)
    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
          let solutions = json["solutions"] as? [[String: Any]] else {
        return nil
    }
    return TopicFileContents(json: json, solutions: solutions)
}

func writeTopicFileContents(_ contents: TopicFileContents, to url: URL) throws {
    var json = contents.json
    json["solutions"] = contents.solutions
    let outputData = try JSONSerialization.data(
        withJSONObject: json,
        options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    )
    try outputData.write(to: url)
}

func compilerErrorSummary(from stderr: String, maxLines: Int = 3) -> String {
    let lines = stderr.components(separatedBy: "\n").filter { $0.contains("error:") }
    return lines.prefix(maxLines).joined(separator: "\n")
}

func firstCompilerErrorLine(from stderr: String) -> String? {
    stderr
        .components(separatedBy: "\n")
        .first(where: { $0.contains("error:") })
}

func unindentOneLevel(_ string: String) -> String {
    string
        .components(separatedBy: "\n")
        .map { line in
            if line.hasPrefix("    ") { return String(line.dropFirst(4)) }
            if line.hasPrefix("\t") { return String(line.dropFirst(1)) }
            return line
        }
        .joined(separator: "\n")
}

func solutionContainerBodyRange(in code: String) -> Range<String.Index>? {
    let classRange = code.range(of: "class Solution")
    let structRange = code.range(of: "struct Solution")
    let containerRange = [classRange, structRange]
        .compactMap { $0 }
        .min(by: { $0.lowerBound < $1.lowerBound })

    guard let containerRange,
          let openBraceIndex = code[containerRange.upperBound...].firstIndex(of: "{") else {
        return nil
    }

    var depth = 0
    var index = openBraceIndex
    var closeBraceIndex: String.Index?

    while index < code.endIndex {
        let ch = code[index]
        if ch == "{" {
            depth += 1
        } else if ch == "}" {
            depth -= 1
            if depth == 0 {
                closeBraceIndex = index
                break
            }
        }
        index = code.index(after: index)
    }

    guard let closeBraceIndex else { return nil }
    let bodyStart = code.index(after: openBraceIndex)
    return bodyStart..<closeBraceIndex
}

func unwrapSolutionContainerIfNeeded(_ code: String) -> String {
    let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let bodyRange = solutionContainerBodyRange(in: trimmed) else {
        return trimmed
    }

    let importLines = trimmed
        .components(separatedBy: "\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { $0.hasPrefix("import ") }

    let body = unindentOneLevel(String(trimmed[bodyRange]))
        .trimmingCharacters(in: .whitespacesAndNewlines)

    if importLines.isEmpty {
        return body
    }

    let uniqueImports = Array(Set(importLines)).sorted()
    return uniqueImports.joined(separator: "\n") + "\n\n" + body
}

func buildRegenerationPrompt(
    slug: String,
    functionSignature: String,
    currentCode: String,
    compilerErrors: String
) -> String {
    """
    Fix this Swift LeetCode solution. It has compilation errors.

    Problem slug: \(slug)
    Function signature: \(functionSignature)

    Current broken code:
    ```swift
    \(currentCode)
    ```

    Compilation errors:
    \(compilerErrors)

    Requirements:
    - Write a correct Swift solution for the LeetCode problem "\(slug)"
    - Use the EXACT same function signature: \(functionSignature)
    - Do NOT include `class Solution { }` wrapper, just class contents
    - Do NOT include `import Foundation` unless truly needed for Foundation types
    - Use proper multi-line formatting (no semicolons as separators)
    - Use String.Index for string subscripting, never str[intIndex]
    - If you need to mutate a parameter, copy it: `var param = param`
    - Return ONLY Swift code, nothing else
    """
}

func regenerateSwiftCode(
    slug: String,
    functionSignature: String,
    currentCode: String,
    compilerErrors: String
) -> String? {
    let prompt = buildRegenerationPrompt(
        slug: slug,
        functionSignature: functionSignature,
        currentCode: currentCode,
        compilerErrors: compilerErrors
    )
    guard let newCode = callGroq(prompt: prompt) else { return nil }
    return unwrapSolutionContainerIfNeeded(newCode)
}

func processApproach(_ approach: inout [String: Any], slug: String) -> ProcessApproachResult {
    guard let code = approach["code"] as? String else {
        return ProcessApproachResult(counts: TopicProcessResult(), modified: false)
    }

    let appName = approach["name"] as? String ?? "?"
    let compileResult = compileSwift(wrapForCompilation(code))

    if compileResult.success {
        return ProcessApproachResult(counts: TopicProcessResult(skipped: 1), modified: false)
    }

    let errorLines = compilerErrorSummary(from: compileResult.stderr, maxLines: 3)
    print("  [\(slug)/\(appName)] COMPILE_ERROR — regenerating...")

    let funcSig = extractFuncSignature(ensureClassSolution(code)) ?? "unknown"
    guard let regenerated = regenerateSwiftCode(
        slug: slug,
        functionSignature: funcSig,
        currentCode: code,
        compilerErrors: errorLines
    ) else {
        print("    Failed to regenerate")
        return ProcessApproachResult(counts: TopicProcessResult(failed: 1), modified: false)
    }

    let newResult = compileSwift(wrapForCompilation(regenerated))
    defer { Thread.sleep(forTimeInterval: 1.0) }

    if newResult.success {
        approach["code"] = regenerated
        print("    Fixed!")
        return ProcessApproachResult(counts: TopicProcessResult(fixed: 1), modified: true)
    }

    let firstError = firstCompilerErrorLine(from: newResult.stderr) ?? ""
    print("    Still fails: \(firstError.prefix(120))")
    return ProcessApproachResult(counts: TopicProcessResult(failed: 1), modified: false)
}

func processApproaches(_ approaches: [[String: Any]], slug: String) -> ProcessApproachesResult {
    if classDesignSlugs.contains(slug) {
        return ProcessApproachesResult(
            approaches: approaches,
            counts: TopicProcessResult(skipped: approaches.count),
            modified: false
        )
    }

    var updated = approaches
    var counts = TopicProcessResult()
    var modified = false

    for index in updated.indices {
        var approach = updated[index]
        let result = processApproach(&approach, slug: slug)
        counts.add(result.counts)
        if result.modified { modified = true }
        updated[index] = approach
    }

    return ProcessApproachesResult(approaches: updated, counts: counts, modified: modified)
}

func processTopic(_ topicId: String, index: SolutionIndex) throws -> TopicProcessResult {
    guard let topicEntry = index.topics.first(where: { $0.id == topicId }) else {
        print("Topic '\(topicId)' not found")
        return TopicProcessResult()
    }

    let topicURL = topicFileURL(for: topicEntry)
    guard var contents = try loadTopicFileContents(from: topicURL) else {
        print("Invalid JSON in \(topicEntry.file)")
        return TopicProcessResult()
    }

    var counts = TopicProcessResult()
    var fileModified = false

    for solIndex in contents.solutions.indices {
        var solution = contents.solutions[solIndex]
        guard let approaches = solution["approaches"] as? [[String: Any]] else { continue }

        let slug = solution["problemSlug"] as? String ?? "?"
        let result = processApproaches(approaches, slug: slug)

        counts.add(result.counts)
        if result.modified { fileModified = true }

        solution["approaches"] = result.approaches
        contents.solutions[solIndex] = solution
    }

    if fileModified {
        try writeTopicFileContents(contents, to: topicURL)
        print("  Saved \(topicEntry.file)")
    }

    return counts
}

// MARK: - Main

print("Solutions directory: \(solutionsDirPath)")
print("Groq model: \(groqModel)")
print()

let topicArg = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil

do {
    let index = try loadIndex()
    let topics: [String]

    if let topicArg {
        topics = [topicArg]
    } else {
        topics = index.topics.map(\.id)
    }

    var totalFixed = 0
    var totalFailed = 0
    var totalSkipped = 0

    for topicId in topics {
        print("=== \(topicId) ===")
        let result = try processTopic(topicId, index: index)
        totalFixed += result.fixed
        totalFailed += result.failed
        totalSkipped += result.skipped
        print("  Fixed: \(result.fixed), Failed: \(result.failed), Skipped: \(result.skipped)")
        print()
    }

    print("=== TOTAL ===")
    print("Fixed: \(totalFixed)")
    print("Failed: \(totalFailed)")
    print("Skipped (already compiling): \(totalSkipped)")

} catch {
    print("ERROR: \(error)")
    exit(1)
}
