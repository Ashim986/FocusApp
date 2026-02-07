import FocusDesignSystem
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

extension CodingEnvironmentView {
    var headerBar: some View {
        DSCard(config: .init(style: .surface, padding: 0, cornerRadius: 0)) {
            HStack(spacing: 0) {
                HStack(spacing: 12) {
                    headerIconButton(
                        systemName: "xmark",
                        help: L10n.Coding.exitHelp,
                        action: onBack
                    )

                    headerIconButton(
                        systemName: "sidebar.leading",
                        help: codingCoordinator.isProblemSidebarShown
                            ? L10n.Coding.hideProblems
                            : L10n.Coding.showProblems,
                        action: { codingCoordinator.toggleProblemSidebar() }
                    )

                    problemSelector
                }
                .padding(.leading, 12)

                Spacer()

                focusTimerIndicator

                Spacer()

                HStack(spacing: 10) {
                    if let problem = presenter.selectedProblem, let url = URL(string: problem.url) {
                        DSButton(
                            L10n.Coding.leetcodeLink,
                            config: .init(
                                style: .ghost,
                                size: .small,
                                icon: Image(systemName: "arrow.up.right"),
                                iconPosition: .leading
                            ),
                            action: { openURL(url) }
                        )
                    }

                    if presenter.isRunning {
                        DSButton(
                            L10n.Coding.stop,
                            config: .init(
                                style: .destructive,
                                size: .small,
                                icon: Image(systemName: "stop.fill"),
                                iconPosition: .leading
                            ),
                            action: presenter.stopExecution
                        )
                        .keyboardShortcut(".", modifiers: .command)
                    } else {
                        DSButton(
                            L10n.Coding.run,
                            config: .init(
                                style: .secondary,
                                size: .small,
                                icon: Image(systemName: "play.fill"),
                                iconPosition: .leading
                            ),
                            action: presenter.runCode
                        )
                        .keyboardShortcut("r", modifiers: .command)

                        DSButton(
                            L10n.Coding.submit,
                            config: .init(
                                style: .primary,
                                size: .small,
                                icon: Image(systemName: "checkmark.circle.fill"),
                                iconPosition: .leading
                            ),
                            action: presenter.runTests
                        )
                        .keyboardShortcut(KeyEquivalent.return, modifiers: [.command, .shift])

                        headerTextButton(
                            title: L10n.Debug.logsTitle,
                            icon: "gearshape",
                            action: { codingCoordinator.showDebugLogs() }
                        )
                        .help(L10n.Debug.logsTitle)

                        headerTextButton(
                            title: L10n.Content.settingsButton,
                            icon: "slider.horizontal.3",
                            action: openSettings
                        )
                        .help(L10n.Content.settingsButton)
                    }
                }
                .padding(.trailing, 12)
            }
            .frame(height: 52)
            .background(theme.colors.surface)
            .overlay(
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(height: 1),
                alignment: .bottom
            )
        }
    }

    private var focusTimerIndicator: some View {
        let remaining = max(focusPresenter.timeRemaining, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        let progress = focusPresenter.progress
        let labelText = focusPresenter.isCompleted
            ? L10n.Coding.timerDone
            : timeString
        let ringStyle: DSProgressRingStyle = focusPresenter.isCompleted ? .secondary : .primary

        return HStack(spacing: 8) {
            DSProgressRing(
                config: .init(size: 18, lineWidth: 2, style: ringStyle),
                state: .init(progress: progress)
            )

            Text(labelText)
                .font(theme.typography.mono)
                .foregroundColor(focusPresenter.isCompleted ? theme.colors.success : theme.colors.textPrimary)

            headerIconButton(
                systemName: "arrow.clockwise",
                help: L10n.Coding.timerRestartHelp,
                action: {
                    focusPresenter.duration = 30
                    focusPresenter.startTimer()
                },
                compact: true
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    private func openSettings() {
        #if canImport(AppKit)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        #endif
    }

    private func headerIconButton(
        systemName: String,
        help: String? = nil,
        action: @escaping () -> Void,
        compact: Bool = false
    ) -> some View {
        let size: CGFloat = compact ? 22 : 28
        return Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: compact ? 9 : 12, weight: .medium))
                .foregroundColor(theme.colors.textSecondary)
                .frame(width: size, height: size)
                .background(theme.colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .help(help ?? "")
    }

    private func headerTextButton(
        title: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        DSButton(
            title,
            config: .init(style: .ghost, size: .small, icon: Image(systemName: icon), iconPosition: .leading),
            action: action
        )
    }
}
