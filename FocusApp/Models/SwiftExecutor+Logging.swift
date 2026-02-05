import Foundation

extension SwiftExecutor {
    func log(level: DebugLogLevel, title: String, message: String, metadata: [String: String] = [:]) {
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

    func logResult(title: String, result: ExecutionResult) {
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

    func filterTraceWarnings(_ value: String) -> String {
        guard !value.isEmpty else { return value }
        let lines = value.split(whereSeparator: \.isNewline)
        var filtered: [String] = []
        var skipNotes = false
        for line in lines {
            let text = String(line)
            if text.contains("warning: expression implicitly coerced from")
                && text.contains("to 'Any'") {
                skipNotes = true
                continue
            }
            if skipNotes {
                if text.contains("note:") {
                    continue
                }
                skipNotes = false
            }
            filtered.append(text)
        }
        return filtered.joined(separator: "\n")
    }

    func trimForLog(_ value: String, limit: Int = 240) -> String {
        guard value.count > limit else { return value }
        return String(value.prefix(limit)) + "…"
    }
}
