import FocusDesignSystem
import SwiftUI

extension FocusOverlay {
    var durationSelector: some View {
        VStack(spacing: DSLayout.spacing(40)) {
            VStack(spacing: DSLayout.spacing(.space8)) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(theme.colors.primary)

                Text(L10n.Focus.durationTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(L10n.Focus.durationPrompt)
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: DSLayout.spacing(20)) {
                HStack(spacing: DSLayout.spacing(20)) {
                    durationButton(minutes: 30)
                    durationButton(minutes: 60)
                    durationButton(minutes: 90)
                }

                HStack(spacing: DSLayout.spacing(20)) {
                    durationButton(minutes: 120)
                    durationButton(minutes: 180)
                    durationButton(minutes: 240)
                }
            }

            HStack(spacing: DSLayout.spacing(.space12)) {
                Text(L10n.Focus.durationCustomLabel)
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
                .frame(width: DSLayout.spacing(80))

                Text(L10n.Focus.durationMinutesLabel)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }

            DSButton(
                L10n.Focus.durationStartButton,
                config: .init(style: .primary, size: .large, icon: Image(systemName: "play.fill")),
                action: { presenter.startTimer() }
            )

            DSButton(
                L10n.Focus.durationCancel,
                config: .init(style: .ghost, size: .small)
            ) {
                closeSession()
            }
        }
    }

    func durationButton(minutes: Int) -> some View {
        let isSelected = presenter.duration == minutes
        return DSButton(
            L10n.Focus.durationButtonFormat(minutes),
            config: .init(style: isSelected ? .primary : .secondary, size: .small),
            action: {
                presenter.duration = minutes
            }
        )
    }
}
