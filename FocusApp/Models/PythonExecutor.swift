import Foundation

/// Executes Python code directly via interpreter
final class PythonExecutor: LanguageExecutor {
    let language: ProgrammingLanguage = .python

    private let processRunner: ProcessRunning
    private let fileManager: FileManager
    private let config: ExecutionConfig
    private let interpreterPath: String
    private let logger: DebugLogRecording?

    init(
        processRunner: ProcessRunning,
        fileManager: FileManager = .default,
        config: ExecutionConfig = .default,
        interpreterPath: String = "/usr/bin/python3",
        logger: DebugLogRecording? = nil
    ) {
        self.processRunner = processRunner
        self.fileManager = fileManager
        self.config = config
        self.interpreterPath = interpreterPath
        self.logger = logger
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
            log(
                level: .error,
                title: "Python write failed",
                message: error.localizedDescription,
                metadata: ["file": sourceFile.path]
            )
            return .failure(AppUserMessage.failedToWriteSource(error.localizedDescription).text)
        }

        // Run
        log(
            level: .info,
            title: "Python run",
            message: "Running \(sourceFile.lastPathComponent)",
            metadata: [
                "interpreter": interpreterPath,
                "input_bytes": "\(input.utf8.count)"
            ]
        )
        let result = await processRunner.run(
            executable: interpreterPath,
            arguments: [sourceFile.path],
            input: input,
            timeout: config.timeout
        )

        logResult(title: "Python run finished", result: result)
        return ExecutionResult(
            output: result.output,
            error: result.error,
            exitCode: result.exitCode,
            timedOut: result.timedOut,
            wasCancelled: result.wasCancelled
        )
    }

    private func log(level: DebugLogLevel, title: String, message: String, metadata: [String: String] = [:]) {
        logger?.recordAsync(
            DebugLogEntry(
                level: level,
                category: .execution,
                title: title,
                message: message,
                metadata: metadata
            )
        )
    }

    private func logResult(title: String, result: ProcessResult) {
        let trimmedError = result.error.isEmpty ? "" : trimForLog(result.error)
        let trimmedOutput = result.output.isEmpty ? "" : trimForLog(result.output)
        var metadata: [String: String] = [
            "timed_out": "\(result.timedOut)",
            "cancelled": "\(result.wasCancelled)"
        ]
        if !trimmedError.isEmpty {
            metadata["error"] = trimmedError
        }
        if !trimmedOutput.isEmpty {
            metadata["output"] = trimmedOutput
        }
        log(
            level: result.exitCode == 0 ? .info : .error,
            title: title,
            message: "Exit \(result.exitCode)",
            metadata: metadata
        )
    }

    private func trimForLog(_ value: String, limit: Int = 240) -> String {
        guard value.count > limit else { return value }
        return String(value.prefix(limit)) + "…"
    }
}
