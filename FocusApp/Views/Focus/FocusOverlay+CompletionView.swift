import FocusDesignSystem
import SwiftUI

extension FocusOverlay {
    var completionView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(theme.colors.success.opacity(0.2))
                    .frame(width: 120, height: 120)

                DSImage(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.success)
            }

            VStack(spacing: 8) {
                DSText(L10n.Focus.completeTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                DSText(L10n.Focus.completeSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.textSecondary)
            }

            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    DSText("\(presenter.minutesFocused)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(theme.colors.primary)
                    DSText(L10n.Focus.completeMinutesLabel)
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            DSButton(
                L10n.Focus.completeDone,
                config: .init(style: .primary, size: .large, icon: DSImage(systemName: "checkmark"))
            ) {
                closeSession()
            }
        }
    }

    func closeSession() {
        presenter.endSession()
        isPresented = false
    }
}
