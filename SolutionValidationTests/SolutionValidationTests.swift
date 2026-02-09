import Foundation
import XCTest

@testable import FocusApp

/// Validates that all bundled solutions compile, run, and produce correct output
/// when wrapped by `LeetCodeExecutionWrapper` and compiled with `swiftc`.
///
/// One test method per topic allows running individual topics in Xcode (Cmd+U).
final class SolutionValidationTests: XCTestCase {
    /// Class-design slugs that use multiple methods and can't be wrapped.
    static let classDesignSlugs: Set<String> = [
        "design-add-and-search-words-data-structure",
        "implement-trie-prefix-tree",
        "word-search-ii",
        "min-stack",
        "lru-cache",
        "lfu-cache",
        "insert-delete-getrandom-o1",
        "design-twitter",
        "kth-largest-element-in-a-stream",
        "find-median-from-data-stream",
        "implement-queue-using-stacks",
        "implement-stack-using-queues",
        "flatten-nested-list-iterator",
        "peeking-iterator",
        "binary-search-tree-iterator",
        "online-stock-span",
        "design-circular-queue",
        "map-sum-pairs",
        "implement-magic-dictionary",
        "time-based-key-value-store",
        "my-calendar-i",
        "my-calendar-ii",
        "range-sum-query-mutable",
        "online-election",
        "encode-and-decode-tinyurl",
        "rle-iterator",
        "first-bad-version",
        "guess-number-higher-or-lower",
        "detect-squares",
        "serialize-and-deserialize-binary-tree",
        "codec",
        "design-hashmap",
        "design-hashset"
    ]

    // MARK: - Per-Topic Tests

    func testArraysHashingSolutions() throws {
        try validateTopic("arrays-hashing")
    }

    func testTwoPointersSolutions() throws {
        try validateTopic("two-pointers")
    }

    func testSlidingWindowSolutions() throws {
        try validateTopic("sliding-window")
    }

    func testStackSolutions() throws {
        try validateTopic("stack")
    }

    func testTriesSolutions() throws {
        try validateTopic("tries")
    }

    func testBinarySearchSolutions() throws {
        try validateTopic("binary-search")
    }

    func testGreedySolutions() throws {
        try validateTopic("greedy")
    }

    func testLinkedListSolutions() throws {
        try validateTopic("linked-list")
    }

    func testIntervalsSolutions() throws {
        try validateTopic("intervals")
    }

    func testTreesSolutions() throws {
        try validateTopic("trees")
    }

    func testHeapSolutions() throws {
        try validateTopic("heap-priority-queue")
    }

    func testBacktrackingSolutions() throws {
        try validateTopic("backtracking")
    }

    func testGraphsSolutions() throws {
        try validateTopic("graphs")
    }

    func testDPSolutions() throws {
        try validateTopic("dynamic-programming")
    }

    func testMathGeometrySolutions() throws {
        try validateTopic("math-geometry")
    }

    func testBitManipulationSolutions() throws {
        try validateTopic("bit-manipulation")
    }

    func testMiscSolutions() throws {
        try validateTopic("misc")
    }

    // MARK: - Validation Engine

    private struct ValidationTotals {
        var passCount = 0
        var failCount = 0
        var skipCount = 0

        mutating func add(_ other: ValidationTotals) {
            passCount += other.passCount
            failCount += other.failCount
            skipCount += other.skipCount
        }
    }

    private func validateTopic(_ topicId: String) throws {
        let solutions = try loadTopicSolutions(topicId)
        guard !solutions.isEmpty else {
            XCTFail("No solutions found for topic '\(topicId)'")
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("focus_validation_\(ProcessInfo.processInfo.processIdentifier)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        var totals = ValidationTotals()
        for solution in solutions {
            let partial = try validateSolution(solution, tempDir: tempDir)
            totals.add(partial)
        }

        print("[\(topicId)] Pass: \(totals.passCount), Fail: \(totals.failCount), Skip: \(totals.skipCount)")
    }

    // MARK: - Helpers

    private func validateSolution(_ solution: ProblemSolution, tempDir: URL) throws -> ValidationTotals {
        if Self.classDesignSlugs.contains(solution.problemSlug) {
            return ValidationTotals(passCount: 0, failCount: 0, skipCount: solution.approaches.count)
        }

        var totals = ValidationTotals()
        for approach in solution.approaches {
            let partial = try validateApproach(
                problemSlug: solution.problemSlug,
                approach: approach,
                tempDir: tempDir
            )
            totals.add(partial)
        }
        return totals
    }

    private func validateApproach(
        problemSlug: String,
        approach: SolutionApproach,
        tempDir: URL
    ) throws -> ValidationTotals {
        var totals = ValidationTotals()

        let code = ensureClassSolution(approach.code)
        guard let meta = makeMinimalMeta(from: code) else {
            totals.skipCount += 1
            return totals
        }

        guard LeetCodeExecutionWrapper.shouldWrap(code: code, language: .swift, meta: meta) else {
            totals.skipCount += 1
            return totals
        }

        let wrapped = LeetCodeExecutionWrapper.wrap(code: code, language: .swift, meta: meta)

        let slugDir = tempDir.appendingPathComponent("\(problemSlug)_\(approach.order)")
        try FileManager.default.createDirectory(at: slugDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: slugDir) }

        let sourceFile = slugDir.appendingPathComponent("solution.swift")
        let binaryFile = slugDir.appendingPathComponent("solution")
        try wrapped.write(to: sourceFile, atomically: true, encoding: .utf8)

        let compileResult = runProcess(
            "/usr/bin/swiftc",
            args: ["-O", "-o", binaryFile.path, sourceFile.path],
            timeout: 30
        )

        guard compileResult.exitCode == 0 else {
            totals.failCount += approach.testCases.count
            for testCase in approach.testCases {
                XCTFail(
                    "COMPILE_ERROR [\(problemSlug)/\(approach.name)] "
                    + "test \(testCase.input.prefix(60)): "
                    + "\(compileResult.stderr.prefix(200))"
                )
            }
            return totals
        }

        for testCase in approach.testCases {
            let runResult = runProcess(binaryFile.path, args: [], input: testCase.input, timeout: 10)

            if runResult.exitCode != 0 {
                totals.failCount += 1
                XCTFail(
                    "RUNTIME_ERROR [\(problemSlug)/\(approach.name)] "
                    + "test \(testCase.input.prefix(60))"
                )
                continue
            }

            let normalized = normalizeOutput(runResult.stdout, expected: testCase.expectedOutput)
            if outputMatches(normalized, expected: testCase.expectedOutput) {
                totals.passCount += 1
            } else {
                totals.failCount += 1
                XCTFail(
                    "WRONG_ANSWER [\(problemSlug)/\(approach.name)] "
                    + "test \(testCase.input.prefix(60)): "
                    + "expected=\(testCase.expectedOutput.prefix(80)) "
                    + "got=\(normalized.prefix(80))"
                )
            }
        }

        return totals
    }

    private func loadTopicSolutions(_ topicId: String) throws -> [ProblemSolution] {
        guard let indexURL = Bundle.main.url(forResource: "index", withExtension: "json") else {
            throw NSError(
                domain: "SolutionValidation", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "index.json not found"]
            )
        }
        let indexData = try Data(contentsOf: indexURL)
        let index = try JSONDecoder().decode(SolutionIndex.self, from: indexData)

        guard let topicMeta = index.topics.first(where: { $0.id == topicId }) else {
            throw NSError(
                domain: "SolutionValidation", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Topic '\(topicId)' not found"]
            )
        }

        let filename = topicMeta.file.replacingOccurrences(of: ".json", with: "")
        guard let topicURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw NSError(
                domain: "SolutionValidation", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "\(topicMeta.file) not found"]
            )
        }

        let data = try Data(contentsOf: topicURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TopicSolutionsBundle.self, from: data).solutions
    }

    private func ensureClassSolution(_ code: String) -> String {
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        if stripped.contains("class Solution") || stripped.contains("struct Solution") {
            return code
        }
        // Extract import statements so they stay at file scope
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

    private func makeMinimalMeta(from code: String) -> LeetCodeMetaData? {
        let sig = LeetCodeExecutionWrapper.swiftFunctionSignature(
            in: code, className: "Solution", methodName: nil
        )
        guard let name = sig?.callName else { return nil }
        return LeetCodeMetaData.decode(from: """
        {"name":"\(name)","params":[],"return":{"type":"void"}}
        """)
    }

    private func normalizeOutput(_ output: String, expected: String) -> String {
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedOutput == trimmedExpected { return trimmedOutput }
        if trimmedOutput.hasSuffix(trimmedExpected) { return trimmedExpected }

        if !trimmedExpected.contains("\n") {
            let lastLine = trimmedOutput.split(whereSeparator: \.isNewline).last
            return lastLine.map(String.init) ?? trimmedOutput
        }
        return trimmedOutput
    }

    private func outputMatches(_ actual: String, expected: String) -> Bool {
        let trimmedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)
        if actual == trimmedExpected { return true }

        // Strip surrounding quotes
        let normActual = stripSurroundingQuotes(actual)
        let normExpected = stripSurroundingQuotes(trimmedExpected)
        if normActual == normExpected { return true }

        // Compact JSON whitespace
        let compactActual = compactJSON(normActual)
        let compactExpected = compactJSON(normExpected)
        return compactActual == compactExpected
    }

    private func stripSurroundingQuotes(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2, trimmed.hasPrefix("\""), trimmed.hasSuffix("\"") {
            let inner = String(trimmed.dropFirst().dropLast())
            if !inner.contains("\"") { return inner }
        }
        return trimmed
    }

    private func compactJSON(_ value: String) -> String {
        value.replacingOccurrences(of: ", ", with: ",")
            .replacingOccurrences(of: ": ", with: ":")
    }
}

private struct ProcessResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}

private func runProcess(
    _ executable: String,
    args: [String],
    input: String? = nil,
    timeout: TimeInterval = 10
) -> ProcessResult {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args

    let stdoutPipe = Pipe()
    let stderrPipe = Pipe()
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe

    if let input {
        let stdinPipe = Pipe()
        process.standardInput = stdinPipe
        if let data = input.data(using: .utf8) {
            stdinPipe.fileHandleForWriting.write(data)
        }
        stdinPipe.fileHandleForWriting.closeFile()
    }

    do {
        try process.run()
    } catch {
        return ProcessResult(stdout: "", stderr: "Failed to launch: \(error)", exitCode: 1)
    }

    let deadline = Date().addingTimeInterval(timeout)
    while process.isRunning, Date() < deadline {
        Thread.sleep(forTimeInterval: 0.05)
    }
    if process.isRunning {
        process.terminate()
        return ProcessResult(stdout: "", stderr: "Timeout after \(Int(timeout))s", exitCode: 1)
    }

    let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
    let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

    return ProcessResult(
        stdout: String(data: stdoutData, encoding: .utf8) ?? "",
        stderr: String(data: stderrData, encoding: .utf8) ?? "",
        exitCode: process.terminationStatus
    )
}
