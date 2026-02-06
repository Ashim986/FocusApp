@testable import FocusApp
import XCTest

final class ExecutorTests: XCTestCase {
    func testExecutionResultFactories() {
        XCTAssertFalse(ExecutionResult.failure("nope").isSuccess)
        XCTAssertTrue(ExecutionResult.timeout().timedOut)
        XCTAssertTrue(ExecutionResult.cancelled().wasCancelled)
    }

    func testSwiftExecutorReturnsCompilationError() async {
        let runner = SpyProcessRunner(
            results: [
                ProcessResult(
                    output: "",
                    error: "bad",
                    exitCode: 1,
                    timedOut: false,
                    wasCancelled: false
                )
            ]
        )
        let executor = SwiftExecutor(
            processRunner: runner,
            config: ExecutionConfig(timeout: 1, tempDirectory: FileManager.default.temporaryDirectory)
        )

        let result = await executor.execute(code: "print(1)", input: "")

        XCTAssertTrue(result.error.contains("Compilation error"))
        XCTAssertEqual(runner.calls.count, 1)
    }

    func testSwiftExecutorReturnsTimeoutOnCompile() async {
        let runner = SpyProcessRunner(
            results: [
                ProcessResult(
                    output: "",
                    error: "",
                    exitCode: 0,
                    timedOut: true,
                    wasCancelled: false
                )
            ]
        )
        let executor = SwiftExecutor(
            processRunner: runner,
            config: ExecutionConfig(timeout: 1, tempDirectory: FileManager.default.temporaryDirectory)
        )

        let result = await executor.execute(code: "print(1)", input: "")

        XCTAssertTrue(result.timedOut)
    }

    func testSwiftExecutorRunsAfterCompile() async {
        let results = [
            ProcessResult(
                output: "",
                error: "",
                exitCode: 0,
                timedOut: false,
                wasCancelled: false
            ),
            ProcessResult(
                output: "ok",
                error: "",
                exitCode: 0,
                timedOut: false,
                wasCancelled: false
            )
        ]
        let runner = SpyProcessRunner(results: results)
        let executor = SwiftExecutor(
            processRunner: runner,
            config: ExecutionConfig(timeout: 1, tempDirectory: FileManager.default.temporaryDirectory)
        )

        let result = await executor.execute(code: "print(1)", input: "")

        XCTAssertEqual(result.output, "ok")
        XCTAssertEqual(runner.calls.count, 2)
        XCTAssertTrue(runner.calls.first?.executable.contains("swiftc") == true)
    }

    func testPythonExecutorRunsInterpreter() async {
        let runner = SpyProcessRunner(
            results: [
                ProcessResult(
                    output: "done",
                    error: "",
                    exitCode: 0,
                    timedOut: false,
                    wasCancelled: false
                )
            ]
        )
        let executor = PythonExecutor(
            processRunner: runner,
            config: ExecutionConfig(timeout: 1, tempDirectory: FileManager.default.temporaryDirectory)
        )

        let result = await executor.execute(code: "print(1)", input: "")

        XCTAssertEqual(result.output, "done")
        XCTAssertEqual(runner.calls.first?.executable, "/usr/bin/python3")
    }

    func testPythonExecutorReturnsFailureWhenWriteFails() async {
        let runner = SpyProcessRunner(results: [])
        let tempDir = URL(fileURLWithPath: "/tmp/nonexistent-\(UUID().uuidString)")
        let executor = PythonExecutor(
            processRunner: runner,
            config: ExecutionConfig(timeout: 1, tempDirectory: tempDir)
        )

        let result = await executor.execute(code: "print(1)", input: "")

        XCTAssertTrue(result.error.contains("Failed to write source file"))
    }
}

private final class SpyProcessRunner: ProcessRunning {
    struct Call {
        let executable: String
        let arguments: [String]
        let input: String
        let timeout: TimeInterval
    }

    private(set) var calls: [Call] = []
    private var results: [ProcessResult]
    private let fileManager: FileManager

    init(results: [ProcessResult], fileManager: FileManager = .default) {
        self.results = results
        self.fileManager = fileManager
    }

    func run(executable: String, arguments: [String], input: String, timeout: TimeInterval) async -> ProcessResult {
        calls.append(
            Call(executable: executable, arguments: arguments, input: input, timeout: timeout)
        )
        if let outputIndex = arguments.firstIndex(of: "-o"), outputIndex + 1 < arguments.count {
            let outputPath = arguments[outputIndex + 1]
            if !fileManager.fileExists(atPath: outputPath) {
                fileManager.createFile(atPath: outputPath, contents: Data(), attributes: nil)
            }
        }
        if results.isEmpty {
            return ProcessResult(
                output: "",
                error: "",
                exitCode: 0,
                timedOut: false,
                wasCancelled: false
            )
        }
        return results.removeFirst()
    }

    func cancelCurrent() { }
}
