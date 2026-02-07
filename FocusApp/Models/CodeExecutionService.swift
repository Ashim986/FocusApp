import Foundation

/// Protocol for code execution - used by presenters
protocol CodeExecuting {
    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult
    func cancelExecution()
}

#if os(macOS)
/// Main service that coordinates code execution across different languages
final class CodeExecutionService: CodeExecuting {
    private let executors: [ProgrammingLanguage: LanguageExecutor]
    private let runner: ProcessRunning?
    private let logger: DebugLogRecording?

    init(
        executors: [ProgrammingLanguage: LanguageExecutor],
        runner: ProcessRunning? = nil,
        logger: DebugLogRecording? = nil
    ) {
        self.executors = executors
        self.runner = runner
        self.logger = logger
    }

    /// Convenience initializer with default executors
    convenience init(config: ExecutionConfig = .default, logger: DebugLogRecording? = nil) {
        let processRunner = ProcessRunner()
        let executors: [ProgrammingLanguage: LanguageExecutor] = [
            .swift: SwiftExecutor(processRunner: processRunner, config: config, logger: logger),
            .python: PythonExecutor(processRunner: processRunner, config: config, logger: logger)
        ]
        self.init(executors: executors, runner: processRunner, logger: logger)
    }

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        guard let executor = executors[language] else {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .execution,
                    title: "Execution failed",
                    message: "Unsupported language: \(language.rawValue)"
                )
            )
            return .failure(AppUserMessage.unsupportedLanguage(language.rawValue).text)
        }
        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .execution,
                title: "Execution started",
                message: "\(language.rawValue) run",
                metadata: [
                    "input_bytes": "\(input.utf8.count)",
                    "code_bytes": "\(code.utf8.count)"
                ]
            )
        )
        let result = await executor.execute(code: code, input: input)
        logger?.recordAsync(
            DebugLogEntry(
                level: result.exitCode == 0 ? .info : .error,
                category: .execution,
                title: "Execution finished",
                message: "\(language.rawValue) exit \(result.exitCode)",
                metadata: [
                    "timed_out": "\(result.timedOut)",
                    "cancelled": "\(result.wasCancelled)"
                ]
            )
        )
        return result
    }

    func cancelExecution() {
        runner?.cancelCurrent()
    }
}

// MARK: - Factory for creating executors

enum ExecutorFactory {
    static func createSwiftExecutor(
        config: ExecutionConfig = .default,
        logger: DebugLogRecording? = nil
    ) -> SwiftExecutor {
        SwiftExecutor(processRunner: ProcessRunner(), config: config, logger: logger)
    }

    static func createPythonExecutor(
        config: ExecutionConfig = .default,
        logger: DebugLogRecording? = nil
    ) -> PythonExecutor {
        PythonExecutor(processRunner: ProcessRunner(), config: config, logger: logger)
    }

    static func createAllExecutors(
        config: ExecutionConfig = .default,
        logger: DebugLogRecording? = nil
    ) -> [ProgrammingLanguage: LanguageExecutor] {
        let processRunner = ProcessRunner()
        return [
            .swift: SwiftExecutor(processRunner: processRunner, config: config, logger: logger),
            .python: PythonExecutor(processRunner: processRunner, config: config, logger: logger)
        ]
    }
}
#endif
