import Foundation
import XCTest

@testable import FocusApp

/// Verifies that the wrapping path used for code execution
/// produces valid code that compiles (Swift) and runs (Python).
///
/// These tests wrap solutions and compile/run them locally to validate the wrapper output.
final class SolutionWrapperIOSTests: XCTestCase {
    /// Class-design slugs that should be skipped.
    private static let classDesignSlugs: Set<String> = SolutionValidationTests.classDesignSlugs

    // MARK: - Swift Wrapping Compilation Tests

    /// Verifies Swift wrapping compiles for all topics.
    func testSwiftWrappingArraysHashing() throws {
        try validateSwiftWrapping("arrays-hashing")
    }

    func testSwiftWrappingTwoPointers() throws {
        try validateSwiftWrapping("two-pointers")
    }

    func testSwiftWrappingSlidingWindow() throws {
        try validateSwiftWrapping("sliding-window")
    }

    func testSwiftWrappingStack() throws {
        try validateSwiftWrapping("stack")
    }

    func testSwiftWrappingTries() throws {
        try validateSwiftWrapping("tries")
    }

    func testSwiftWrappingBinarySearch() throws {
        try validateSwiftWrapping("binary-search")
    }

    func testSwiftWrappingGreedy() throws {
        try validateSwiftWrapping("greedy")
    }

    func testSwiftWrappingLinkedList() throws {
        try validateSwiftWrapping("linked-list")
    }

    func testSwiftWrappingIntervals() throws {
        try validateSwiftWrapping("intervals")
    }

    func testSwiftWrappingTrees() throws {
        try validateSwiftWrapping("trees")
    }

    func testSwiftWrappingHeap() throws {
        try validateSwiftWrapping("heap-priority-queue")
    }

    func testSwiftWrappingBacktracking() throws {
        try validateSwiftWrapping("backtracking")
    }

    func testSwiftWrappingGraphs() throws {
        try validateSwiftWrapping("graphs")
    }

    func testSwiftWrappingDP() throws {
        try validateSwiftWrapping("dynamic-programming")
    }

    func testSwiftWrappingMathGeometry() throws {
        try validateSwiftWrapping("math-geometry")
    }

    func testSwiftWrappingBitManipulation() throws {
        try validateSwiftWrapping("bit-manipulation")
    }

    func testSwiftWrappingMisc() throws {
        try validateSwiftWrapping("misc")
    }

    // NOTE: Python wrapping test removed — all bundled solutions are Swift-only.
    // The Python wrapper (wrapPython) expects Python code input, not Swift.
    // When Python solutions are added (with a language field on SolutionApproach),
    // a Python wrapping validation test can be added here.

    // MARK: - Swift Validation Engine

    private func validateSwiftWrapping(_ topicId: String) throws {
        let solutions = try loadTopicSolutions(topicId)
        guard !solutions.isEmpty else {
            XCTFail("No solutions found for topic '\(topicId)'")
            return
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("focus_wrap_validation_\(ProcessInfo.processInfo.processIdentifier)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        var compilePass = 0
        var compileFail = 0
        var skipCount = 0

        for solution in solutions {
            if Self.classDesignSlugs.contains(solution.problemSlug) {
                skipCount += solution.approaches.count
                continue
            }

            for approach in solution.approaches {
                let code = ensureClassSolution(approach.code)
                guard let meta = makeMinimalMeta(from: code) else {
                    skipCount += 1
                    continue
                }

                guard LeetCodeExecutionWrapper.shouldWrap(
                    code: code, language: .swift, meta: meta
                ) else {
                    skipCount += 1
                    continue
                }

                let wrapped = LeetCodeExecutionWrapper.wrap(
                    code: code, language: .swift, meta: meta
                )

                let slugDir = tempDir.appendingPathComponent(
                    "\(solution.problemSlug)_\(approach.order)"
                )
                try FileManager.default.createDirectory(at: slugDir, withIntermediateDirectories: true)

                let sourceFile = slugDir.appendingPathComponent("solution.swift")
                let binaryFile = slugDir.appendingPathComponent("solution")
                try wrapped.write(to: sourceFile, atomically: true, encoding: .utf8)

                let compileResult = runProcess(
                    "/usr/bin/swiftc",
                    args: ["-O", "-o", binaryFile.path, sourceFile.path],
                    timeout: 30
                )

                if compileResult.exitCode == 0 {
                    compilePass += 1

                    // Also run first test case if available to verify runtime
                    if let firstTest = approach.testCases.first {
                        let runResult = runProcess(
                            binaryFile.path, args: [], input: firstTest.input, timeout: 10
                        )
                        if runResult.exitCode != 0 {
                            compileFail += 1
                            compilePass -= 1
                            XCTFail(
                                "RUNTIME_ERROR [\(solution.problemSlug)/\(approach.name)]: "
                                + "crashed on first test case"
                            )
                        }
                    }
                } else {
                    compileFail += 1
                    XCTFail(
                        "COMPILE_ERROR [\(solution.problemSlug)/\(approach.name)]: "
                        + "\(compileResult.stderr.prefix(200))"
                    )
                }

                // Clean up to save disk space
                try? FileManager.default.removeItem(at: slugDir)
            }
        }

        print(
            "[\(topicId)] Compile pass: \(compilePass), fail: \(compileFail), skip: \(skipCount)"
        )
    }

    // MARK: - Helpers

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
}
