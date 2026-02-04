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
            Label(L10n.Settings.validationValid, systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        case .invalid:
            Label(L10n.Settings.validationNotFound, systemImage: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .none:
            EmptyView()
        }
    }
}
