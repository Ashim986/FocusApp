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

    // swiftlint:disable cyclomatic_complexity function_body_length
    private func runInternal(
        executable: String,
        arguments: [String],
        input: String,
        timeout: TimeInterval
    ) async -> ProcessResult {
        if Task.isCancelled {
            return ProcessResult(
                output: "",
                error: AppUserMessage.executionStopped.text,
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

                let collector = ProcessOutputCollector(maxOutputLength: maxOutputLength)

                let cancelHandler: () -> Void = {
                    if process.isRunning {
                        process.terminate()
                    }
                }

                await state.setCancelHandler(cancelHandler)

                @Sendable func handleOutput(_ data: Data) {
                    collector.appendOutput(data)
                    if collector.outputLimitExceeded && process.isRunning {
                        process.terminate()
                    }
                }

                @Sendable func handleError(_ data: Data) {
                    collector.appendError(data)
                    if collector.errorLimitExceeded && process.isRunning {
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

                    if !collector.outputLimitExceeded {
                        let remaining = outputPipe.fileHandleForReading.readDataToEndOfFile()
                        if !remaining.isEmpty {
                            handleOutput(remaining)
                        }
                    }

                    if !collector.errorLimitExceeded {
                        let remaining = errorPipe.fileHandleForReading.readDataToEndOfFile()
                        if !remaining.isEmpty {
                            handleError(remaining)
                        }
                    }

                    outputPipe.fileHandleForReading.closeFile()
                    errorPipe.fileHandleForReading.closeFile()

                    let flags = await state.flags()
                    let output = collector.outputString(truncate: self.truncateIfNeeded)
                    var error = collector.errorString(truncate: self.truncateIfNeeded)

                    if collector.outputLimitExceeded || collector.errorLimitExceeded {
                        let limitMessage = AppUserMessage.outputLimitExceeded.text
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
                        error: AppUserMessage.failedToRunProcess(error.localizedDescription).text,
                        exitCode: -1,
                        timedOut: false,
                        wasCancelled: false
                    ))
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length

    private func truncateIfNeeded(_ text: String) -> String {
        if text.count > maxOutputLength {
            return String(text.prefix(maxOutputLength)) + "\n[FocusApp] Output truncated (exceeded limit)"
        }
        return text
    }
}
