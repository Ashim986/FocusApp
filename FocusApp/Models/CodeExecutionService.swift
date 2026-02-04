import Foundation

/// Protocol for code execution - used by presenters
protocol CodeExecuting {
    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult
    func cancelExecution()
}

/// Main service that coordinates code execution across different languages
final class CodeExecutionService: CodeExecuting {
    private let executors: [ProgrammingLanguage: LanguageExecutor]
    private let runner: ProcessRunning?

    init(executors: [ProgrammingLanguage: LanguageExecutor], runner: ProcessRunning? = nil) {
        self.executors = executors
        self.runner = runner
    }

    /// Convenience initializer with default executors
    convenience init(config: ExecutionConfig = .default) {
        let processRunner = ProcessRunner()
        let executors: [ProgrammingLanguage: LanguageExecutor] = [
            .swift: SwiftExecutor(processRunner: processRunner, config: config),
            .python: PythonExecutor(processRunner: processRunner, config: config)
        ]
        self.init(executors: executors, runner: processRunner)
    }

    func execute(code: String, language: ProgrammingLanguage, input: String) async -> ExecutionResult {
        guard let executor = executors[language] else {
            return .failure("Unsupported language: \(language.rawValue)")
        }
        return await executor.execute(code: code, input: input)
    }

    func cancelExecution() {
        runner?.cancelCurrent()
    }
}

// MARK: - Factory for creating executors

enum ExecutorFactory {
    static func createSwiftExecutor(config: ExecutionConfig = .default) -> SwiftExecutor {
        SwiftExecutor(processRunner: ProcessRunner(), config: config)
    }

    static func createPythonExecutor(config: ExecutionConfig = .default) -> PythonExecutor {
        PythonExecutor(processRunner: ProcessRunner(), config: config)
    }

    static func createAllExecutors(config: ExecutionConfig = .default) -> [ProgrammingLanguage: LanguageExecutor] {
        let processRunner = ProcessRunner()
        return [
            .swift: SwiftExecutor(processRunner: processRunner, config: config),
            .python: PythonExecutor(processRunner: processRunner, config: config)
        ]
    }
}
