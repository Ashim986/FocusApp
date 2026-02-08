#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension FocusOverlay {
    var timerView: some View {
        VStack(spacing: DSLayout.spacing(40)) {
            ZStack {
                DSProgressRing(
                    config: .init(size: 280, lineWidth: 12, style: .primary),
                    state: .init(progress: presenter.progress)
                )
                .animation(.linear(duration: 1), value: presenter.progress)

                VStack(spacing: DSLayout.spacing(8)) {
                    Text(presenter.timeString)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(presenter.isPaused
                        ? L10n.Focus.timerPaused
                        : L10n.Focus.timerRemaining)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Text(L10n.Focus.timerPrompt)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(theme.colors.textSecondary)

            HStack(spacing: DSLayout.spacing(20)) {
                DSButton(
                    presenter.isPaused ? L10n.Focus.timerResume : L10n.Focus.timerPause,
                    config: .init(
                        style: .secondary,
                        size: .medium,
                        icon: Image(systemName: presenter.isPaused ? "play.fill" : "pause.fill")
                    )
                ) {
                    presenter.togglePause()
                }

                DSButton(
                    L10n.Focus.timerEndSession,
                    config: .init(style: .destructive, size: .medium, icon: Image(systemName: "xmark"))
                ) {
                    closeSession()
                }
            }
        }
    }
}

#endif
