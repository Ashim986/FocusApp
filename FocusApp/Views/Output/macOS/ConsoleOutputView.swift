#if os(macOS)
import FocusDesignSystem
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct ConsoleOutputView: View {
    let output: String
    @Environment(\.dsTheme) var theme

    private var lines: [ConsoleLine] {
        output.components(separatedBy: "\n").enumerated().map { index, content in
            ConsoleLine(
                number: index + 1,
                content: content,
                type: detectLineType(content)
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(0)) {
            ForEach(lines) { line in
                ConsoleLineView(line: line)
            }
        }
        .padding(DSLayout.spacing(8))
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
        )
    }

    private func detectLineType(_ content: String) -> ConsoleLineType {
        let lowercased = content.lowercased()

        if lowercased.contains("error") || lowercased.contains("exception") ||
           lowercased.contains("fatal") || lowercased.contains("failed") ||
           content.hasPrefix("E ") || content.hasPrefix("[ERROR]") ||
           content.hasPrefix("[E]") {
            return .error
        }

        if lowercased.contains("warning") || lowercased.contains("warn") ||
           content.hasPrefix("W ") || content.hasPrefix("[WARNING]") ||
           content.hasPrefix("[WARN]") || content.hasPrefix("[W]") {
            return .warning
        }

        if lowercased.contains("[info]") || lowercased.contains("[debug]") ||
           content.hasPrefix("I ") || content.hasPrefix("D ") ||
           content.hasPrefix("[I]") || content.hasPrefix("[D]") {
            return .info
        }

        if lowercased.contains("success") || lowercased.contains("passed") ||
           lowercased.contains("completed") || lowercased.contains("✓") ||
           lowercased.contains("done") {
            return .success
        }

        return .standard
    }
}

struct ConsoleLine: Identifiable {
    let id = UUID()
    let number: Int
    let content: String
    let type: ConsoleLineType
}

enum ConsoleLineType {
    case standard
    case error
    case warning
    case info
    case success

    func color(theme: DSTheme) -> Color {
        switch self {
        case .standard: return theme.colors.textPrimary
        case .error: return theme.colors.danger
        case .warning: return theme.colors.warning
        case .info: return theme.colors.accent
        case .success: return theme.colors.success
        }
    }

    var icon: String? {
        switch self {
        case .standard: return nil
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }
}

struct ConsoleLineView: View {
    let line: ConsoleLine
    @Environment(\.dsTheme) var theme

    var body: some View {
        let lineColor = line.type.color(theme: theme)
        HStack(alignment: .top, spacing: DSLayout.spacing(0)) {
            Text("\(line.number)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(theme.colors.textSecondary)
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, DSLayout.spacing(8))

            Rectangle()
                .fill(theme.colors.border)
                .frame(width: 1)
                .padding(.trailing, DSLayout.spacing(8))

            if let icon = line.type.icon {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(lineColor)
                    .frame(width: 12)
                    .padding(.trailing, DSLayout.spacing(4))
            }

            Text(line.content.isEmpty ? " " : line.content)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(lineColor)
                .textSelection(.enabled)

            Spacer(minLength: 0)

            DSButton(
                "Copy",
                config: .init(style: .ghost, size: .small, icon: Image(systemName: "doc.on.doc"))
            ) {
                copyLine()
            }
            .padding(.leading, DSLayout.spacing(8))
        }
        .padding(.vertical, DSLayout.spacing(2))
        .background(
            line.type == .error ? theme.colors.danger.opacity(0.1) :
            line.type == .warning ? theme.colors.warning.opacity(0.1) :
            Color.clear
        )
    }

    private func copyLine() {
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(line.content, forType: .string)
        #endif
    }
}

#endif
