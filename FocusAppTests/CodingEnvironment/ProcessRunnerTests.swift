@testable import FocusApp
import XCTest

final class ProcessRunnerTests: XCTestCase {
    func testRunEchoReturnsOutput() async {
        let runner = ProcessRunner()
        let result = await runner.run(
            executable: "/bin/echo",
            arguments: ["hello"],
            input: "",
            timeout: 1
        )

        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.output.contains("hello"))
        XCTAssertFalse(result.timedOut)
    }

    func testRunInvalidExecutableReturnsFailure() async {
        let runner = ProcessRunner()
        let result = await runner.run(
            executable: "/bin/does-not-exist",
            arguments: [],
            input: "",
            timeout: 1
        )

        XCTAssertNotEqual(result.exitCode, 0)
        XCTAssertTrue(result.error.contains("Failed to run process"))
    }

    func testRunTimesOut() async {
        let runner = ProcessRunner()
        let result = await runner.run(
            executable: "/bin/sleep",
            arguments: ["1"],
            input: "",
            timeout: 0.05
        )

        XCTAssertTrue(result.timedOut)
    }

    func testRunCancelled() async {
        let runner = ProcessRunner()
        let task = Task {
            await runner.run(
                executable: "/bin/sleep",
                arguments: ["2"],
                input: "",
                timeout: 5
            )
        }

        try? await Task.sleep(nanoseconds: 50_000_000)
        runner.cancelCurrent()

        let result = await task.value
        XCTAssertTrue(result.wasCancelled)
    }

    func testRunOutputLimitAddsError() async {
        let runner = ProcessRunner(maxOutputLength: 10)
        let result = await runner.run(
            executable: "/bin/sh",
            arguments: ["-c", "printf '12345678901234567890'"],
            input: "",
            timeout: 1
        )

        XCTAssertTrue(result.error.contains("output exceeded limit"))
    }
}
