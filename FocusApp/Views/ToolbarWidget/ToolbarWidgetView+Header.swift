import AppKit
import SwiftUI

extension ToolbarWidgetView {
    var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Widget.headerTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                if !presenter.lastSyncResult.isEmpty {
                    Text(presenter.lastSyncResult)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                } else {
                    Text(L10n.Widget.headerReady)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: { presenter.syncNow() }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12))
                        .foregroundColor(presenter.isSyncing ? .green : .white.opacity(0.6))
                        .rotationEffect(.degrees(presenter.isSyncing ? 360 : 0))
                        .animation(presenter.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: presenter.isSyncing)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
                .disabled(presenter.isSyncing)
                .help(L10n.Widget.headerSyncHelp)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                        if showSettings {
                            presenter.beginEditingUsername()
                        }
                    }
                }) {
                    Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(showSettings ? .blue : .white.opacity(0.6))
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.06))
                        )
                }
                .buttonStyle(.plain)
                .help(L10n.Widget.headerSettingsHelp)
            }
        }
    }
}
