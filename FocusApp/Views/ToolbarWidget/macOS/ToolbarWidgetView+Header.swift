#if os(macOS)
import AppKit
import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var header: some View {
        HStack(spacing: DSLayout.spacing(12)) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.primary, theme.colors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.colors.surface)
            }
            .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                Text(L10n.Widget.headerTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                if !presenter.lastSyncResult.isEmpty {
                    Text(presenter.lastSyncResult)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(theme.colors.success)
                        .padding(.horizontal, DSLayout.spacing(6))
                        .padding(.vertical, DSLayout.spacing(2))
                        .background(
                            Capsule()
                                .fill(theme.colors.success.opacity(0.15))
                        )
                } else {
                    Text(L10n.Widget.headerReady)
                        .font(.system(size: 9))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            HStack(spacing: DSLayout.spacing(8)) {
                DSActionButton(action: {
                    presenter.syncNow()
                }, label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
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
                .disabled(presenter.isSyncing)
                .help(L10n.Widget.headerSyncHelp)

                DSActionButton(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                        if showSettings {
                            presenter.beginEditingUsername()
                        }
                    }
                }, label: {
                    Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(showSettings ? theme.colors.primary : theme.colors.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(theme.colors.surfaceElevated.opacity(0.6))
                        )
                })
                .help(L10n.Widget.headerSettingsHelp)
            }
        }
    }
}
#endif
