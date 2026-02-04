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
            Label("Valid", systemImage: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
        case .invalid:
            Label("Not Found", systemImage: "xmark.circle.fill")
                .foregroundColor(.red)
                .font(.caption)
        case .none:
            EmptyView()
        }
    }
}
