import FocusDesignSystem
import SwiftUI

extension SettingsView {
    var validationBorderColor: Color {
        switch presenter.usernameValidationState {
        case .valid:
            return .green
        case .invalid:
            return .red
        case .none:
            return .clear
        }
    }

    @ViewBuilder
    var validationStatusView: some View {
        switch presenter.usernameValidationState {
        case .valid:
            HStack(spacing: 6) {
                DSImage(systemName: "checkmark.circle.fill")
                DSText(L10n.Settings.validationValid)
            }
            .foregroundColor(.green)
            .font(.caption)
        case .invalid:
            HStack(spacing: 6) {
                DSImage(systemName: "xmark.circle.fill")
                DSText(L10n.Settings.validationNotFound)
            }
            .foregroundColor(.red)
            .font(.caption)
        case .none:
            EmptyView()
        }
    }
}
