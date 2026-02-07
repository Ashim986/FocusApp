import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var settingsSection: some View {
        VStack(spacing: 8) {
            HStack {
                DSText(L10n.Widget.leetcodeUsername)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()

                switch presenter.usernameValidationState {
                case .valid:
                    HStack(spacing: 2) {
                        DSImage(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        DSText(L10n.Widget.validationValid)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(theme.colors.success)
                case .invalid:
                    HStack(spacing: 2) {
                        DSImage(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                        DSText(L10n.Widget.validationNotFound)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(theme.colors.danger)
                case .none:
                    EmptyView()
                }
            }

            HStack(spacing: 8) {
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

                DSButton(action: {
                    presenter.validateAndSaveUsername()
                }, label: {
                    HStack(spacing: 4) {
                        if presenter.isValidatingUsername {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 12, height: 12)
                        } else {
                            DSImage(systemName: "arrow.clockwise")
                                .font(.system(size: 10))
                        }
                        DSText(presenter.isValidatingUsername
                             ? L10n.Widget.checking
                             : L10n.Widget.saveSync)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(theme.colors.surface)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                presenter.isValidatingUsername
                                    ? theme.colors.surfaceElevated.opacity(0.7)
                                    : theme.colors.primary
                            )
                    )
                })
                .buttonStyle(.plain)
                .disabled(presenter.isValidatingUsername)
            }

            HStack {
                DSImage(systemName: "info.circle")
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                DSText(L10n.Widget.leetcodePublicNotice)
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()
            }
        }
    }

}
