import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var settingsSection: some View {
        VStack(spacing: DSLayout.spacing(8)) {
            HStack {
                Text(L10n.Widget.leetcodeUsername)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()

                switch presenter.usernameValidationState {
                case .valid:
                    HStack(spacing: DSLayout.spacing(2)) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text(L10n.Widget.validationValid)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(theme.colors.success)
                case .invalid:
                    HStack(spacing: DSLayout.spacing(2)) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                        Text(L10n.Widget.validationNotFound)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(theme.colors.danger)
                case .none:
                    EmptyView()
                }
            }

            HStack(spacing: DSLayout.spacing(8)) {
                let validation: DSTextFieldValidation = {
                    switch presenter.usernameValidationState {
                    case .valid:
                        return .valid
                    case .invalid:
                        return .invalid(nil)
                    case .none:
                        return .none
                    }
                }()

                DSTextField(
                    placeholder: L10n.Widget.usernamePlaceholder,
                    text: $presenter.editingUsername,
                    config: DSTextFieldConfig(style: .outlined, size: .small),
                    state: DSTextFieldState(validation: validation)
                )
                .onSubmit {
                    presenter.validateAndSaveUsername()
                }
                .onChange(of: presenter.editingUsername) { _, _ in
                    presenter.resetValidationState()
                }

                DSButton(
                    presenter.isValidatingUsername
                        ? L10n.Widget.checking
                        : L10n.Widget.saveSync,
                    config: .init(
                        style: .primary,
                        size: .small,
                        icon: Image(systemName: "arrow.clockwise"),
                        iconPosition: .leading
                    ),
                    state: .init(
                        isEnabled: !presenter.isValidatingUsername,
                        isLoading: presenter.isValidatingUsername
                    ),
                    action: {
                        presenter.validateAndSaveUsername()
                    }
                )
            }

            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                Text(L10n.Widget.leetcodePublicNotice)
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()
            }
        }
    }

}
