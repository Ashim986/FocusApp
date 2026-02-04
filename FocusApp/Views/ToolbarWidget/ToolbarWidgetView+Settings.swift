import SwiftUI

extension ToolbarWidgetView {
    var settingsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text(L10n.Widget.leetcodeUsername)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()

                switch presenter.usernameValidationState {
                case .valid:
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                        Text(L10n.Widget.validationValid)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(.green)
                case .invalid:
                    HStack(spacing: 2) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                        Text(L10n.Widget.validationNotFound)
                            .font(.system(size: 9))
                    }
                    .foregroundColor(.red)
                case .none:
                    EmptyView()
                }
            }

            HStack(spacing: 8) {
                TextField(L10n.Widget.usernamePlaceholder, text: $presenter.editingUsername)
                    .textFieldStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(validationBorderColor, lineWidth: 1)
                    )
                    .onSubmit {
                        presenter.validateAndSaveUsername()
                    }
                    .onChange(of: presenter.editingUsername) { _, _ in
                        presenter.resetValidationState()
                    }

                Button(action: {
                    presenter.validateAndSaveUsername()
                }, label: {
                    HStack(spacing: 4) {
                        if presenter.isValidatingUsername {
                            ProgressView()
                                .scaleEffect(0.6)
                                .frame(width: 12, height: 12)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10))
                        }
                        Text(presenter.isValidatingUsername
                             ? L10n.Widget.checking
                             : L10n.Widget.saveSync)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(presenter.isValidatingUsername ? Color.gray : Color.blue)
                    )
                })
                .buttonStyle(.plain)
                .disabled(presenter.isValidatingUsername)
            }

            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                Text(L10n.Widget.leetcodePublicNotice)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }

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
}
