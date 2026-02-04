import SwiftUI

extension FocusOverlay {
    var completionView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.appGreen)
            }

            VStack(spacing: 8) {
                Text(L10n.Focus.completeTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text(L10n.Focus.completeSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }

            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(presenter.minutesFocused)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.appPurple)
                    Text(L10n.Focus.completeMinutesLabel)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Button(action: { closeSession() }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                    Text(L10n.Focus.completeDone)
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appGreen)
                )
            }
            .buttonStyle(.plain)
        }
    }

    func closeSession() {
        presenter.endSession()
        isPresented = false
    }
}
