import FocusDesignSystem
import SwiftUI

extension DebugLogView {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Debug.logsTitle)
                    .font(.title3.weight(.semibold))

                HStack(spacing: 8) {
                    statusChip(title: "Live", color: theme.colors.success)
                    Text("Last \(lastEntryTimestamp)")
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            Spacer()
            Text("\(store.entries.count)")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.colors.surfaceElevated.opacity(0.8))
                )
            if let onClose {
                Button(action: onClose, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(theme.colors.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                })
                .buttonStyle(.plain)
                .help("Close")
            }
            DSButton(L10n.Debug.copyLogs) {
                copyLogs()
            }
            .buttonStyle(.bordered)
            DSButton(L10n.Debug.clearLogs) {
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
                color: theme.colors.textSecondary,
                isSelected: selectedLevel == .all
            ) {
                selectedLevel = .all
            }
            summaryPill(
                title: DebugLogLevel.error.rawValue,
                count: counts.error,
                color: theme.colors.danger,
                isSelected: selectedLevel == .error
            ) {
                selectedLevel = .error
            }
            summaryPill(
                title: DebugLogLevel.warning.rawValue,
                count: counts.warning,
                color: theme.colors.warning,
                isSelected: selectedLevel == .warning
            ) {
                selectedLevel = .warning
            }
            summaryPill(
                title: DebugLogLevel.info.rawValue,
                count: counts.info,
                color: theme.colors.accent,
                isSelected: selectedLevel == .info
            ) {
                selectedLevel = .info
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(theme.colors.surfaceElevated)
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
                    .fill(isSelected ? theme.colors.surfaceElevated : theme.colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? color.opacity(0.7) : theme.colors.border, lineWidth: 1)
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
