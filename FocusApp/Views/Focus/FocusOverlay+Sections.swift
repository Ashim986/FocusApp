import FocusDesignSystem
import SwiftUI

extension FocusOverlay {
    var durationSelector: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                DSImage(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.colors.primary)

                DSText(L10n.Focus.durationTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                DSText(L10n.Focus.durationPrompt)
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    durationButton(minutes: 30)
                    durationButton(minutes: 60)
                    durationButton(minutes: 90)
                }

                HStack(spacing: 20) {
                    durationButton(minutes: 120)
                    durationButton(minutes: 180)
                    durationButton(minutes: 240)
                }
            }

            HStack(spacing: 12) {
                DSText(L10n.Focus.durationCustomLabel)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)

                TextField("", value: $presenter.duration, format: .number)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)
                    .frame(width: 60)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.colors.surfaceElevated)
                    )

                DSText(L10n.Focus.durationMinutesLabel)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }

            DSButton(
                L10n.Focus.durationStartButton,
                config: .init(style: .primary, size: .large, icon: DSImage(systemName: "play.fill"))
            ) {
                presenter.startTimer()
            }

            DSButton(action: {
                closeSession()
            }, label: {
                DSText(L10n.Focus.durationCancel)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            })
            .buttonStyle(.plain)
        }
    }

    func durationButton(minutes: Int) -> some View {
        DSButton(action: {
            presenter.duration = minutes
        }, label: {
            DSText(L10n.Focus.durationButtonFormat(minutes))
                .font(.system(size: 14, weight: presenter.duration == minutes ? .semibold : .regular))
                .foregroundColor(presenter.duration == minutes ? theme.colors.primary : theme.colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(presenter.duration == minutes ? theme.colors.surface : theme.colors.surfaceElevated)
                )
        })
        .buttonStyle(.plain)
    }
}
