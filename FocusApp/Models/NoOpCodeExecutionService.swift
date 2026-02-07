import Foundation

/// Stub code execution service for iOS where Process() is unavailable.
/// Returns an error message directing users to submit to LeetCode.
final class NoOpCodeExecutionService: CodeExecuting {
    func execute(
        code: String,
        language: ProgrammingLanguage,
        input: String
    ) async -> ExecutionResult {
        ExecutionResult(
            output: "",
            error: "Code execution is not available on iOS. Submit to LeetCode to test your solution.",
            exitCode: 1,
            timedOut: false,
            wasCancelled: false
        )
    }

    func cancelExecution() {}
}
