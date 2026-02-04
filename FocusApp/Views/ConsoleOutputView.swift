import SwiftUI

struct ConsoleOutputView: View {
    let output: String

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
        VStack(alignment: .leading, spacing: 0) {
            ForEach(lines) { line in
                ConsoleLineView(line: line)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.appGray700, lineWidth: 1)
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

    var color: Color {
        switch self {
        case .standard: return .white
        case .error: return Color.appRed
        case .warning: return Color.appAmber
        case .info: return Color(red: 0.35, green: 0.78, blue: 0.98)
        case .success: return Color.appGreen
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

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text("\(line.number)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color.appGray600)
                .frame(width: 28, alignment: .trailing)
                .padding(.trailing, 8)

            Rectangle()
                .fill(Color.appGray700)
                .frame(width: 1)
                .padding(.trailing, 8)

            if let icon = line.type.icon {
                Image(systemName: icon)
                    .font(.system(size: 9))
                    .foregroundColor(line.type.color)
                    .frame(width: 12)
                    .padding(.trailing, 4)
            }

            Text(line.content.isEmpty ? " " : line.content)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(line.type.color)
                .textSelection(.enabled)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .background(
            line.type == .error ? Color.appRed.opacity(0.1) :
            line.type == .warning ? Color.appAmber.opacity(0.1) :
            Color.clear
        )
    }
}
