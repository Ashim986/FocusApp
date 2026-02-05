import SwiftUI

extension DebugLogView {
    var entryCounts: DebugLogCounts {
        var infoCount = 0
        var warningCount = 0
        var errorCount = 0
        for entry in store.entries {
            switch entry.level {
            case .info:
                infoCount += 1
            case .warning:
                warningCount += 1
            case .error:
                errorCount += 1
            }
        }
        return DebugLogCounts(
            total: store.entries.count,
            info: infoCount,
            warning: warningCount,
            error: errorCount
        )
    }

    var lastEntryTimestamp: String {
        guard let entry = store.entries.first else {
            return "—"
        }
        return Self.timestampFormatter.string(from: entry.timestamp)
    }

    func copyLogs() {
        let lines = filteredEntries.map { entry in
            let time = Self.timestampFormatter.string(from: entry.timestamp)
            let meta = entry.metadata
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
            let metaSuffix = meta.isEmpty ? "" : " | \(meta)"
            return "[\(time)] [\(entry.level.rawValue)] [\(entry.category.rawValue)] \(entry.title) - \(entry.message)\(metaSuffix)"
        }
        let text = lines.joined(separator: "\n")
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
