import Foundation

/// Executes Swift code by compiling and running
final class SwiftExecutor: LanguageExecutor {
    let language: ProgrammingLanguage = .swift

    private let processRunner: ProcessRunning
    private let fileManager: FileManager
    private let config: ExecutionConfig
    private let compilerPath: String

    init(
        processRunner: ProcessRunning,
        fileManager: FileManager = .default,
        config: ExecutionConfig = .default,
        compilerPath: String = "/usr/bin/swiftc"
    ) {
        self.processRunner = processRunner
        self.fileManager = fileManager
        self.config = config
        self.compilerPath = compilerPath
    }

    func execute(code: String, input: String) async -> ExecutionResult {
        let uniqueID = UUID().uuidString
        let sourceFile = config.tempDirectory.appendingPathComponent("solution_\(uniqueID).swift")
        let executableFile = config.tempDirectory.appendingPathComponent("solution_\(uniqueID)")

        // Cleanup on exit
        defer {
            try? fileManager.removeItem(at: sourceFile)
            try? fileManager.removeItem(at: executableFile)
        }

        // Write source file
        do {
            try code.write(to: sourceFile, atomically: true, encoding: .utf8)
        } catch {
            return .failure(AppUserMessage.failedToWriteSource(error.localizedDescription).text)
        }

        // Compile
        let compileResult = await compile(sourceFile: sourceFile, outputFile: executableFile)
        if !compileResult.isSuccess {
            return compileResult
        }

        // Run
        return await run(executableFile: executableFile, input: input)
    }

    private func compile(sourceFile: URL, outputFile: URL) async -> ExecutionResult {
        let result = await processRunner.run(
            executable: compilerPath,
            arguments: ["-o", outputFile.path, sourceFile.path],
            input: "",
            timeout: config.timeout
        )

        if result.wasCancelled {
            return .cancelled()
        }

        if result.timedOut {
            return .timeout()
        }

        if result.exitCode != 0 {
            return ExecutionResult(
                output: "",
                error: "\(L10n.Error.compilationErrorPrefix)\n\(result.error)",
                exitCode: result.exitCode,
                timedOut: false,
                wasCancelled: result.wasCancelled
            )
        }

        return ExecutionResult(
            output: result.output,
            error: result.error,
            exitCode: result.exitCode,
            timedOut: false,
            wasCancelled: result.wasCancelled
        )
    }

    private func run(executableFile: URL, input: String) async -> ExecutionResult {
        let result = await processRunner.run(
            executable: executableFile.path,
            arguments: [],
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
