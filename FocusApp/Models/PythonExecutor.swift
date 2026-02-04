import Foundation

/// Executes Python code directly via interpreter
final class PythonExecutor: LanguageExecutor {
    let language: ProgrammingLanguage = .python

    private let processRunner: ProcessRunning
    private let fileManager: FileManager
    private let config: ExecutionConfig
    private let interpreterPath: String

    init(
        processRunner: ProcessRunning,
        fileManager: FileManager = .default,
        config: ExecutionConfig = .default,
        interpreterPath: String = "/usr/bin/python3"
    ) {
        self.processRunner = processRunner
        self.fileManager = fileManager
        self.config = config
        self.interpreterPath = interpreterPath
    }

    func execute(code: String, input: String) async -> ExecutionResult {
        let uniqueID = UUID().uuidString
        let sourceFile = config.tempDirectory.appendingPathComponent("solution_\(uniqueID).py")

        // Cleanup on exit
        defer {
            try? fileManager.removeItem(at: sourceFile)
        }

        // Write source file
        do {
            try code.write(to: sourceFile, atomically: true, encoding: .utf8)
        } catch {
            return .failure(AppUserMessage.failedToWriteSource(error.localizedDescription).text)
        }

        // Run
        let result = await processRunner.run(
            executable: interpreterPath,
            arguments: [sourceFile.path],
            input: input,
            timeout: config.timeout
        )

        return ExecutionResult(
            output: result.output,
            error: result.error,
            exitCode: result.exitCode,
            timedOut: result.timedOut,
            wasCancelled: result.wasCancelled
        )
    }
}
