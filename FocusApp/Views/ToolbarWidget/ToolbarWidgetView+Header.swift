import AppKit
import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                DSImage(systemName: "brain.head.profile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.colors.surface)
            }
            .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 2) {
                DSText(L10n.Widget.headerTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                if !presenter.lastSyncResult.isEmpty {
                    DSText(presenter.lastSyncResult)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(theme.colors.success)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(theme.colors.success.opacity(0.15))
                        )
                } else {
                    DSText(L10n.Widget.headerReady)
                        .font(.system(size: 9))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                DSButton(action: {
                    presenter.syncNow()
                }, label: {
                    DSImage(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12))
                        .foregroundColor(presenter.isSyncing ? theme.colors.success : theme.colors.textSecondary)
                        .rotationEffect(.degrees(presenter.isSyncing ? 360 : 0))
                        .animation(
                            presenter.isSyncing
                                ? .linear(duration: 1).repeatForever(autoreverses: false)
                                : .default,
                            value: presenter.isSyncing
                        )
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(theme.colors.surfaceElevated.opacity(0.6))
                        )
                })
                .buttonStyle(.plain)
                .disabled(presenter.isSyncing)
                .help(L10n.Widget.headerSyncHelp)

                DSButton(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                        if showSettings {
                            presenter.beginEditingUsername()
                        }
                    }
                }, label: {
                    DSImage(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(showSettings ? theme.colors.primary : theme.colors.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(theme.colors.surfaceElevated.opacity(0.6))
                        )
                })
                .buttonStyle(.plain)
                .help(L10n.Widget.headerSettingsHelp)
            }
        }
    }
}
