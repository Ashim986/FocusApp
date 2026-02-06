import Foundation

/// Executes Swift code by compiling and running
final class SwiftExecutor: LanguageExecutor {
    let language: ProgrammingLanguage = .swift

    private let processRunner: ProcessRunning
    private let fileManager: FileManager
    private let config: ExecutionConfig
    private let compilerPath: String
    private let sdkPath: String?
    let logger: DebugLogRecording?

    init(
        processRunner: ProcessRunning,
        fileManager: FileManager = .default,
        config: ExecutionConfig = .default,
        compilerPath: String? = nil,
        logger: DebugLogRecording? = nil
    ) {
        self.processRunner = processRunner
        self.fileManager = fileManager
        self.config = config
        let resolved = Self.resolveToolchain(fileManager: fileManager)
        self.compilerPath = compilerPath ?? resolved.compilerPath
        self.sdkPath = compilerPath == nil
            ? resolved.sdkPath
            : Self.resolveSDKPath(forCompilerPath: compilerPath, fileManager: fileManager) ?? resolved.sdkPath
        self.logger = logger
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

        if let writeFailure = writeSourceFile(code: code, to: sourceFile) {
            return writeFailure
        }

        if let compileFailure = await compileSource(sourceFile: sourceFile, outputFile: executableFile) {
            return compileFailure
        }

        if let validationFailure = validateExecutable(at: executableFile) {
            return validationFailure
        }

        // Run
        log(
            level: .info,
            title: "Swift run",
            message: "Running \(executableFile.lastPathComponent)",
            metadata: ["input_bytes": "\(input.utf8.count)"]
        )
        let runResult = await run(executableFile: executableFile, input: input)
        logResult(title: "Swift run finished", result: runResult)
        return runResult
    }

    private func writeSourceFile(code: String, to url: URL) -> ExecutionResult? {
        do {
            try code.write(to: url, atomically: true, encoding: .utf8)
            return nil
        } catch {
            log(
                level: .error,
                title: "Swift write failed",
                message: error.localizedDescription,
                metadata: ["file": url.path]
            )
            return .failure(AppUserMessage.failedToWriteSource(error.localizedDescription).text)
        }
    }

    private func compileSource(sourceFile: URL, outputFile: URL) async -> ExecutionResult? {
        log(
            level: .info,
            title: "Swift compile",
            message: "Compiling \(sourceFile.lastPathComponent)",
            metadata: [
                "compiler": compilerPath,
                "sdk": sdkPath ?? "default"
            ]
        )
        let compileResult = await compile(sourceFile: sourceFile, outputFile: outputFile)
        if compileResult.timedOut {
            logResult(title: "Swift compile timed out", result: compileResult)
            return compileResult
        }
        if compileResult.wasCancelled {
            logResult(title: "Swift compile cancelled", result: compileResult)
            return compileResult
        }
        if compileResult.exitCode != 0 {
            logResult(title: "Swift compile failed", result: compileResult)
            return compileResult
        }
        let filteredWarning = filterTraceWarnings(compileResult.error)
        if !filteredWarning.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            log(
                level: .warning,
                title: "Swift compile warning",
                message: "Compiler emitted warnings.",
                metadata: [
                    "warning": trimForLog(filteredWarning)
                ]
            )
            let sanitized = ExecutionResult(
                output: compileResult.output,
                error: "",
                exitCode: compileResult.exitCode,
                timedOut: compileResult.timedOut,
                wasCancelled: compileResult.wasCancelled
            )
            logResult(title: "Swift compile finished", result: sanitized)
        } else {
            logResult(title: "Swift compile finished", result: compileResult)
        }
        return nil
    }

    private func validateExecutable(at url: URL) -> ExecutionResult? {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        if !exists || isDirectory.boolValue {
            log(
                level: .error,
                title: "Executable missing",
                message: "Swift compiler did not produce output binary.",
                metadata: [
                    "output": url.path
                ]
            )
            return .failure(AppUserMessage.failedToRunProcess("Compiled executable is missing.").text)
        }
        if !fileManager.isExecutableFile(atPath: url.path) {
            log(
                level: .warning,
                title: "Executable not marked",
                message: "Output binary is not marked executable.",
                metadata: [
                    "output": url.path
                ]
            )
        }
        return nil
    }

    private func compile(sourceFile: URL, outputFile: URL) async -> ExecutionResult {
        var arguments: [String] = []
        if let sdkPath {
            arguments.append(contentsOf: ["-sdk", sdkPath])
        }
        arguments.append(contentsOf: ["-o", outputFile.path, sourceFile.path])

        let result = await processRunner.run(
            executable: compilerPath,
            arguments: arguments,
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

    private static func resolveToolchain(fileManager: FileManager) -> (compilerPath: String, sdkPath: String?) {
        let developerDir = ProcessInfo.processInfo.environment["DEVELOPER_DIR"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let developerRoots: [String] = [
            developerDir,
            "/Applications/Xcode_26.app/Contents/Developer",
            "/Applications/Xcode.app/Contents/Developer"
        ].compactMap { $0?.isEmpty == false ? $0 : nil }

        for root in developerRoots {
            let compiler = "\(root)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc"
            if fileManager.isExecutableFile(atPath: compiler) {
                let sdk = resolveSDKPath(in: root, fileManager: fileManager)
                return (compiler, sdk)
            }
        }

        let cltCompiler = "/Library/Developer/CommandLineTools/usr/bin/swiftc"
        if fileManager.isExecutableFile(atPath: cltCompiler) {
            let sdk = resolveSDKPath(in: "/Library/Developer/CommandLineTools", fileManager: fileManager)
            return (cltCompiler, sdk)
        }

        return ("/usr/bin/swiftc", nil)
    }

    private static func resolveSDKPath(
        forCompilerPath compilerPath: String?,
        fileManager: FileManager
    ) -> String? {
        guard let compilerPath else { return nil }
        if compilerPath.contains("/CommandLineTools/") {
            return resolveSDKPath(in: "/Library/Developer/CommandLineTools", fileManager: fileManager)
        }
        if let range = compilerPath.range(of: "/Toolchains/") {
            let prefix = String(compilerPath[..<range.lowerBound])
            return resolveSDKPath(in: prefix, fileManager: fileManager)
        }
        return nil
    }

    private static func resolveSDKPath(in root: String, fileManager: FileManager) -> String? {
        let sdkRoots = [
            "\(root)/Platforms/MacOSX.platform/Developer/SDKs",
            "\(root)/SDKs"
        ]

        for sdkRoot in sdkRoots {
            guard let entries = try? fileManager.contentsOfDirectory(atPath: sdkRoot) else { continue }
            let sdkCandidates = entries
                .filter { $0.hasPrefix("MacOSX") && $0.hasSuffix(".sdk") }
                .sorted()
                .reversed()
            if let sdk = sdkCandidates.first {
                return "\(sdkRoot)/\(sdk)"
            }
        }

        return nil
    }

}
