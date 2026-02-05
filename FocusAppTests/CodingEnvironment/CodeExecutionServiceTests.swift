@testable import FocusApp
import XCTest

final class CodeExecutionServiceTests: XCTestCase {
    func testExecuteUsesConfiguredExecutor() async {
        let expected = ExecutionResult(output: "ok", error: "", exitCode: 0, timedOut: false, wasCancelled: false)
        let executor = FakeLanguageExecutor(language: .swift, result: expected)
        let service = CodeExecutionService(executors: [.swift: executor])

        let result = await service.execute(code: "print(1)", language: .swift, input: "")

        XCTAssertEqual(result.output, "ok")
        XCTAssertEqual(result.error, "")
        XCTAssertEqual(result.exitCode, 0)
    }

    func testExecuteReturnsFailureForUnsupportedLanguage() async {
        let executor = FakeLanguageExecutor(language: .swift, result: .failure("unused"))
        let service = CodeExecutionService(executors: [.swift: executor])

        let result = await service.execute(code: "", language: .python, input: "")

        XCTAssertEqual(result.error, "Unsupported language: Python")
        XCTAssertEqual(result.exitCode, -1)
    }

    func testCancelExecutionUsesRunner() {
        let runner = SpyProcessRunnerForService()
        let service = CodeExecutionService(executors: [:], runner: runner)

        service.cancelExecution()

        XCTAssertTrue(runner.didCancel)
    }

    func testExecutorFactoryCreatesExecutors() {
        let executors = ExecutorFactory.createAllExecutors()

        XCTAssertNotNil(executors[.swift])
        XCTAssertNotNil(executors[.python])
    }
}

private final class SpyProcessRunnerForService: ProcessRunning {
    private(set) var didCancel = false

    func run(executable: String, arguments: [String], input: String, timeout: TimeInterval) async -> ProcessResult {
        ProcessResult(output: "", error: "", exitCode: 0, timedOut: false, wasCancelled: false)
    }

    func cancelCurrent() {
        didCancel = true
    }
}
