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

                let durationText = Binding<String>(
                    get: { "\(presenter.duration)" },
                    set: { newValue in
                        if let value = Int(newValue) {
                            presenter.duration = value
                        }
                    }
                )

                DSTextField(
                    placeholder: "",
                    text: durationText,
                    config: DSTextFieldConfig(style: .outlined, size: .small)
                )
                .frame(width: 80)

                DSText(L10n.Focus.durationMinutesLabel)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }

            DSButton(config: .init(style: .primary, size: .large), action: {
                presenter.startTimer()
            }, label: {
                HStack(spacing: 8) {
                    DSImage(systemName: "play.fill")
                    DSText(L10n.Focus.durationStartButton)
                }
            })

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
