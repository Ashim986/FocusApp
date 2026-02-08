#if os(macOS)
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

    private func runInternal(
        executable: String,
        arguments: [String],
        input: String,
        timeout: TimeInterval
    ) async -> ProcessResult {
        guard Task.isCancelled == false else { return makeCancelledResult() }

        return await withCheckedContinuation { continuation in
            Task {
                await state.reset()
                let process = makeProcess(executable: executable, arguments: arguments)
                let io = ProcessIO(maxOutputLength: maxOutputLength)
                io.attach(to: process)

                await state.setCancelHandler { [weak self, weak process] in
                    guard let self, let process else { return }
                    self.terminate(process)
                }

                io.installReadabilityHandlers { [weak self, weak process] in
                    guard let self, let process else { return }
                    self.terminate(process)
                }

                let timeoutTask = startTimeoutTask(timeout: timeout, process: process)
                let result = await runProcess(process, io: io, input: input, timeoutTask: timeoutTask)
                continuation.resume(returning: result)
            }
        }
    }

    private func makeCancelledResult() -> ProcessResult {
        ProcessResult(
            output: "",
            error: AppUserMessage.executionStopped.text,
            exitCode: -1,
            timedOut: false,
            wasCancelled: true
        )
    }

    private func makeProcess(executable: String, arguments: [String]) -> Process {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        return process
    }

    private func terminate(_ process: Process) {
        guard process.isRunning else { return }
        process.terminate()
    }

    private func startTimeoutTask(timeout: TimeInterval, process: Process) -> Task<Void, Never> {
        Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            } catch {
                return
            }
            await state.markTimedOut()
            terminate(process)
        }
    }

    private func runProcess(
        _ process: Process,
        io: ProcessIO,
        input: String,
        timeoutTask: Task<Void, Never>
    ) async -> ProcessResult {
        defer { timeoutTask.cancel() }
        do {
            try process.run()
            writeInput(input, to: io.inputPipe)
            process.waitUntilExit()

            io.clearReadabilityHandlers()
            io.drainRemainingData()
            io.closeReadHandles()

            let flags = await state.flags()
            await state.clearCancelHandler()
            return makeResult(process: process, collector: io.collector, flags: flags)
        } catch {
            io.clearReadabilityHandlers()
            io.closeAllHandles()
            await state.clearCancelHandler()
            return ProcessResult(
                output: "",
                error: AppUserMessage.failedToRunProcess(error.localizedDescription).text,
                exitCode: -1,
                timedOut: false,
                wasCancelled: false
            )
        }
    }

    private func writeInput(_ input: String, to pipe: Pipe) {
        if !input.isEmpty, let inputData = input.data(using: .utf8) {
            pipe.fileHandleForWriting.write(inputData)
        }
        pipe.fileHandleForWriting.closeFile()
    }

    private func makeResult(
        process: Process,
        collector: ProcessOutputCollector,
        flags: (wasCancelled: Bool, didTimeout: Bool)
    ) -> ProcessResult {
        let output = collector.outputString(truncate: truncateIfNeeded)
        var error = collector.errorString(truncate: truncateIfNeeded)

        if collector.outputLimitExceeded || collector.errorLimitExceeded {
            let limitMessage = AppUserMessage.outputLimitExceeded.text
            if error.isEmpty {
                error = limitMessage
            } else {
                error += "\n\(limitMessage)"
            }
        }

        return ProcessResult(
            output: output,
            error: error,
            exitCode: process.terminationStatus,
            timedOut: flags.didTimeout,
            wasCancelled: flags.wasCancelled
        )
    }

    private func truncateIfNeeded(_ text: String) -> String {
        if text.count > maxOutputLength {
            return String(text.prefix(maxOutputLength)) + "\n[FocusApp] Output truncated (exceeded limit)"
        }
        return text
    }
}

private final class ProcessIO {
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    let inputPipe = Pipe()
    let collector: ProcessOutputCollector

    init(maxOutputLength: Int) {
        collector = ProcessOutputCollector(maxOutputLength: maxOutputLength)
    }

    func attach(to process: Process) {
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.standardInput = inputPipe
    }

    func installReadabilityHandlers(terminate: @escaping () -> Void) {
        outputPipe.fileHandleForReading.readabilityHandler = { [collector] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            collector.appendOutput(data)
            if collector.outputLimitExceeded {
                terminate()
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { [collector] handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            collector.appendError(data)
            if collector.errorLimitExceeded {
                terminate()
            }
        }
    }

    func clearReadabilityHandlers() {
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
    }

    func drainRemainingData() {
        if !collector.outputLimitExceeded {
            let remaining = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if !remaining.isEmpty {
                collector.appendOutput(remaining)
            }
        }

        if !collector.errorLimitExceeded {
            let remaining = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if !remaining.isEmpty {
                collector.appendError(remaining)
            }
        }
    }

    func closeReadHandles() {
        outputPipe.fileHandleForReading.closeFile()
        errorPipe.fileHandleForReading.closeFile()
    }

    func closeAllHandles() {
        closeReadHandles()
        inputPipe.fileHandleForWriting.closeFile()
    }
}
#endif
