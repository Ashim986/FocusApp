import SwiftUI

extension DebugLogView {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Debug.logsTitle)
                    .font(.title3.weight(.semibold))

                HStack(spacing: 8) {
                    statusChip(title: "Live", color: Color.appGreen)
                    Text("Last \(lastEntryTimestamp)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.appGray400)
                }
            }
            Spacer()
            Text("\(store.entries.count)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.appGray800.opacity(0.8))
                )
            if let onClose {
                Button(action: onClose, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.appGray300)
                        .frame(width: 28, height: 28)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                })
                .buttonStyle(.plain)
                .help("Close")
            }
            Button(L10n.Debug.copyLogs) {
                copyLogs()
            }
            .buttonStyle(.bordered)
            Button(L10n.Debug.clearLogs) {
                store.clear()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(headerBackground)
    }

    var summary: some View {
        let counts = entryCounts
        return HStack(spacing: 10) {
            summaryPill(
                title: L10n.Debug.levelAll,
                count: counts.total,
                color: Color.appGray500,
                isSelected: selectedLevel == .all
            ) {
                selectedLevel = .all
            }
            summaryPill(
                title: DebugLogLevel.error.rawValue,
                count: counts.error,
                color: Color.appRed,
                isSelected: selectedLevel == .error
            ) {
                selectedLevel = .error
            }
            summaryPill(
                title: DebugLogLevel.warning.rawValue,
                count: counts.warning,
                color: Color.appAmber,
                isSelected: selectedLevel == .warning
            ) {
                selectedLevel = .warning
            }
            summaryPill(
                title: DebugLogLevel.info.rawValue,
                count: counts.info,
                color: Color.appCyan,
                isSelected: selectedLevel == .info
            ) {
                selectedLevel = .info
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color.appGray800)
    }

    private func summaryPill(
        title: String,
        count: Int,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action, label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appGray700 : Color.appGray900)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color.opacity(0.7) : Color.appGray700, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
    }

    private func statusChip(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}
