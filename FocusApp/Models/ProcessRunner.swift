import Foundation

/// Result of running a process
struct ProcessResult {
    let output: String
    let error: String
    let exitCode: Int32
    let timedOut: Bool
    let wasCancelled: Bool

    var isSuccess: Bool {
        exitCode == 0 && !timedOut && !wasCancelled
    }
}

/// Protocol for running system processes
protocol ProcessRunning {
    func run(
        executable: String,
        arguments: [String],
        input: String,
        timeout: TimeInterval
    ) async -> ProcessResult
    func cancelCurrent()
}

actor ProcessRunState {
    private var currentCancel: (() -> Void)?
    private var wasCancelled = false
    private var didTimeout = false

    func reset() {
        currentCancel = nil
        wasCancelled = false
        didTimeout = false
    }

    func setCancelHandler(_ handler: @escaping () -> Void) {
        currentCancel = handler
    }

    func cancel() {
        wasCancelled = true
        currentCancel?()
    }

    func markTimedOut() {
        didTimeout = true
    }

    func clearCancelHandler() {
        currentCancel = nil
    }

    func flags() -> (wasCancelled: Bool, didTimeout: Bool) {
        (wasCancelled, didTimeout)
    }
}

/// Runs system processes with timeout support
final class ProcessRunner: ProcessRunning {
    private let maxOutputLength: Int
    private let state = ProcessRunState()

    init(maxOutputLength: Int = 10 * 1024) {
        self.maxOutputLength = maxOutputLength
    }

    func run(
        executable: String,
        arguments: [String],
        input: String,
        timeout: TimeInterval
    ) async -> ProcessResult {
        await withTaskCancellationHandler {
            await runInternal(
                executable: executable,
                arguments: arguments,
                input: input,
                timeout: timeout
            )
        } onCancel: {
            cancelCurrent()
        }
    }

    func cancelCurrent() {
        Task {
            await state.cancel()
        }
    }

    private func runInternal(
        executable: String,
        arguments: [String],
        input: String,
        timeout: TimeInterval
    ) async -> ProcessResult {
        if Task.isCancelled {
            return ProcessResult(
                output: "",
                error: "Execution stopped by user",
                exitCode: -1,
                timedOut: false,
                wasCancelled: true
            )
        }
        return await withCheckedContinuation { continuation in
            Task {
                await state.reset()
                let process = Process()
                process.executableURL = URL(fileURLWithPath: executable)
                process.arguments = arguments

                let outputPipe = Pipe()
                let errorPipe = Pipe()
                let inputPipe = Pipe()

                process.standardOutput = outputPipe
                process.standardError = errorPipe
                process.standardInput = inputPipe

                var outputLimitExceeded = false
                var errorLimitExceeded = false

                let outputLock = NSLock()
                var outputData = Data()
                var errorData = Data()

                let cancelHandler: () -> Void = {
                    if process.isRunning {
                        process.terminate()
                    }
                }

                await state.setCancelHandler(cancelHandler)

                func appendData(_ data: Data, to buffer: inout Data, limitExceeded: inout Bool) {
                    guard !limitExceeded else { return }
                    if buffer.count >= maxOutputLength {
                        limitExceeded = true
                        return
                    }
                    let remaining = maxOutputLength - buffer.count
                    if data.count > remaining {
                        buffer.append(data.prefix(remaining))
                        limitExceeded = true
                    } else {
                        buffer.append(data)
                    }
                }

                @Sendable func handleOutput(_ data: Data) {
                    outputLock.lock()
                    appendData(data, to: &outputData, limitExceeded: &outputLimitExceeded)
                    let shouldTerminate = outputLimitExceeded
                    outputLock.unlock()
                    if shouldTerminate && process.isRunning {
                        process.terminate()
                    }
                }

                @Sendable func handleError(_ data: Data) {
                    outputLock.lock()
                    appendData(data, to: &errorData, limitExceeded: &errorLimitExceeded)
                    let shouldTerminate = errorLimitExceeded
                    outputLock.unlock()
                    if shouldTerminate && process.isRunning {
                        process.terminate()
                    }
                }

                outputPipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        handleOutput(data)
                    }
                }

                errorPipe.fileHandleForReading.readabilityHandler = { handle in
                    let data = handle.availableData
                    if !data.isEmpty {
                        handleError(data)
                    }
                }

                let timeoutTask = Task {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    } catch {
                        return
                    }
                    await state.markTimedOut()
                    if process.isRunning {
                        process.terminate()
                    }
                }

                do {
                    try process.run()

                    if !input.isEmpty, let inputData = input.data(using: .utf8) {
                        inputPipe.fileHandleForWriting.write(inputData)
                    }
                    inputPipe.fileHandleForWriting.closeFile()

                    process.waitUntilExit()
                    timeoutTask.cancel()

                    outputPipe.fileHandleForReading.readabilityHandler = nil
                    errorPipe.fileHandleForReading.readabilityHandler = nil

                    if !outputLimitExceeded {
                        let remaining = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        if !remaining.isEmpty {
                            handleOutput(remaining)
                        }
                    }

                    if !errorLimitExceeded {
                        let remaining = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        if !remaining.isEmpty {
                            handleError(remaining)
                        }
                    }

                    outputPipe.fileHandleForReading.closeFile()
                    errorPipe.fileHandleForReading.closeFile()

                    let flags = await state.flags()
                    let output = self.truncateIfNeeded(String(data: outputData, encoding: .utf8) ?? "")
                    var error = self.truncateIfNeeded(String(data: errorData, encoding: .utf8) ?? "")

                    if outputLimitExceeded || errorLimitExceeded {
                        let limitMessage = "Execution stopped: output exceeded limit."
                        if error.isEmpty {
                            error = limitMessage
                        } else {
                            error += "\n\(limitMessage)"
                        }
                    }

                    await state.clearCancelHandler()

                    continuation.resume(returning: ProcessResult(
                        output: output,
                        error: error,
                        exitCode: process.terminationStatus,
                        timedOut: flags.didTimeout,
                        wasCancelled: flags.wasCancelled
                    ))
                } catch {
                    timeoutTask.cancel()
                    await state.clearCancelHandler()
                    continuation.resume(returning: ProcessResult(
                        output: "",
                        error: "Failed to run process: \(error.localizedDescription)",
                        exitCode: -1,
                        timedOut: false,
                        wasCancelled: false
                    ))
                }
            }
        }
    }

    private func truncateIfNeeded(_ text: String) -> String {
        if text.count > maxOutputLength {
            return String(text.prefix(maxOutputLength)) + "\n... (output truncated)"
        }
        return text
    }
}
