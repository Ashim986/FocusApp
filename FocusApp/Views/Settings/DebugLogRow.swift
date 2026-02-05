import SwiftUI

struct DebugLogRow: View {
    let entry: DebugLogEntry
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(levelColor)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text(Self.timestampFormatter.string(from: entry.timestamp))
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
                    }

                    Text(entry.message)
                        .font(.system(size: 11))
                        .foregroundColor(Color.appGray300)
                        .lineLimit(isExpanded ? nil : 2)

                    if isExpanded, !entry.metadata.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(entry.metadata.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                Text("\(key): \(value)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(Color.appGray400)
                            }
                        }
                    }
                }
            }

            if !entry.metadata.isEmpty {
                Button(isExpanded ? L10n.Debug.hideDetails : L10n.Debug.showDetails) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .buttonStyle(.plain)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.appPurple)
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
    }

    private var levelColor: Color {
        switch entry.level {
        case .info:
            return Color.appCyan
        case .warning:
            return Color.appAmber
        case .error:
            return Color.appRed
        }
    }

    private var levelBackground: Color {
        switch entry.level {
        case .info:
            return Color.appGreenLight.opacity(0.12)
        case .warning:
            return Color.appAmberLight.opacity(0.18)
        case .error:
            return Color.appRedLight.opacity(0.2)
        }
    }

    private var levelBorder: Color {
        switch entry.level {
        case .info:
            return Color.appGreen.opacity(0.5)
        case .warning:
            return Color.appAmber.opacity(0.6)
        case .error:
            return Color.appRed.opacity(0.6)
        }
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
