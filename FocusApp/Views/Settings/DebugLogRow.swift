import FocusDesignSystem
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct DebugLogRow: View {
    let entry: DebugLogEntry
    @State private var isExpanded = false
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(levelColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center, spacing: 8) {
                        DSText(entry.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                        Spacer()
                        DSText(Self.timestampFormatter.string(from: entry.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                        DSImage(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)
                        DSButton(action: copyEntry) {
                            DSImage(systemName: "doc.on.doc")
                                .font(.system(size: 10))
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        .buttonStyle(.plain)
                        .help("Copy log")
                    }

                    DSText(entry.message)
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(isExpanded ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let detail = primaryDetail {
                        DSText(detail)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textSecondary)
                            .lineLimit(isExpanded ? nil : 3)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if isExpanded {
                        if isNetwork {
                            if let curl = networkCurl {
                                detailSection(title: "cURL", value: curl)
                            }
                            if let request = networkRequestDetail {
                                detailSection(title: "Request", value: request)
                            }
                            if let response = networkResponseDetail {
                                detailSection(title: "Response", value: response)
                            }
                            if !supplementalMetadata.isEmpty {
                                metadataSection(supplementalMetadata)
                            }
                        } else if !entry.metadata.isEmpty {
                            metadataSection(sortedMetadata)
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(levelBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(levelBorder, lineWidth: 1)
        )
        .listRowSeparator(.hidden)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }

    private var levelColor: Color {
        switch entry.level {
        case .info:
            return theme.colors.accent
        case .warning:
            return theme.colors.warning
        case .error:
            return theme.colors.danger
        }
    }

    private var levelBackground: Color {
        switch entry.level {
        case .info:
            return theme.colors.accent.opacity(0.12)
        case .warning:
            return theme.colors.warning.opacity(0.18)
        case .error:
            return theme.colors.danger.opacity(0.2)
        }
    }

    private var levelBorder: Color {
        switch entry.level {
        case .info:
            return theme.colors.accent.opacity(0.5)
        case .warning:
            return theme.colors.warning.opacity(0.6)
        case .error:
            return theme.colors.danger.opacity(0.6)
        }
    }

    private var isNetwork: Bool {
        entry.category == .network
    }

    private var networkRequestDetail: String? {
        entry.metadata["request"]
    }

    private var networkResponseDetail: String? {
        entry.metadata["response"]
    }

    private var networkCurl: String? {
        entry.metadata["curl"]
    }

    private var primaryDetail: String? {
        let metadata = entry.metadata
        if let error = metadata["error"], !error.isEmpty {
            return error
        }
        if let warning = metadata["warning"], !warning.isEmpty {
            return warning
        }
        if let stderr = metadata["stderr"], !stderr.isEmpty {
            return stderr
        }
        if entry.level == .error {
            return nil
        }
        return nil
    }

    private var sortedMetadata: [(key: String, value: String)] {
        let preferredOrder = [
            "method",
            "url",
            "status",
            "duration_ms",
            "bytes",
            "curl",
            "request",
            "response"
        ]
        return entry.metadata.sorted { left, right in
            let leftIndex = preferredOrder.firstIndex(of: left.key) ?? Int.max
            let rightIndex = preferredOrder.firstIndex(of: right.key) ?? Int.max
            if leftIndex != rightIndex {
                return leftIndex < rightIndex
            }
            return left.key < right.key
        }
    }

    private var supplementalMetadata: [(key: String, value: String)] {
        sortedMetadata.filter { key, _ in
            key != "request" && key != "response" && key != "curl"
        }
    }

    private func copyEntry() {
        let time = Self.timestampFormatter.string(from: entry.timestamp)
        var lines: [String] = [
            "[\(time)] [\(entry.level.rawValue)] [\(entry.category.rawValue)] \(entry.title)",
            entry.message
        ]
        if !entry.metadata.isEmpty {
            for (key, value) in sortedMetadata {
                if value.contains("\n") {
                    lines.append("\(key):")
                    lines.append(value)
                } else {
                    lines.append("\(key): \(value)")
                }
            }
        }
        let text = lines.joined(separator: "\n")
        #if canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    @ViewBuilder
    private func detailSection(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                DSText(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()
                DSButton(
                    action: { copySection(title: title, value: value) },
                    label: {
                        DSImage(systemName: "doc.on.doc")
                            .font(.system(size: 9))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                )
                .buttonStyle(.plain)
                .help("Copy \(title.lowercased())")
            }
            DSText(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(theme.colors.textSecondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
        .background(theme.colors.surfaceElevated.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private func metadataSection(_ items: [(key: String, value: String)]) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(items, id: \.key) { key, value in
                if value.contains("\n") {
                    VStack(alignment: .leading, spacing: 2) {
                        DSText("\(key):")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)
                        DSText(value)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textSecondary)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    DSText("\(key): \(value)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(theme.colors.textSecondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func copySection(title: String, value: String) {
        #if canImport(AppKit)
        let text = "\(title):\n\(value)"
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
