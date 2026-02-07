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
            HStack(spacing: DSLayout.spacing(6)) {
                Image(systemName: "checkmark.circle.fill")
                Text(L10n.Settings.validationValid)
            }
            .foregroundColor(.green)
            .font(.caption)
        case .invalid:
            HStack(spacing: DSLayout.spacing(6)) {
                Image(systemName: "xmark.circle.fill")
                Text(L10n.Settings.validationNotFound)
            }
            .foregroundColor(.red)
            .font(.caption)
        case .none:
            EmptyView()
        }
    }
}
