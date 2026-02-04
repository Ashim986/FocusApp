import SwiftUI

extension FocusOverlay {
    var timerView: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 280, height: 280)

                Circle()
                    .trim(from: 0, to: presenter.progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appPurple, Color(hex: "#8b5cf6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: presenter.progress)

                VStack(spacing: 8) {
                    Text(presenter.timeString)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(presenter.isPaused
                        ? L10n.Focus.timerPaused
                        : L10n.Focus.timerRemaining)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Text(L10n.Focus.timerPrompt)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 20) {
                Button(action: presenter.togglePause, label: {
                    HStack(spacing: 8) {
                        Image(systemName: presenter.isPaused ? "play.fill" : "pause.fill")
                        Text(presenter.isPaused
                            ? L10n.Focus.timerResume
                            : L10n.Focus.timerPause)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.15))
                    )
                })
                .buttonStyle(.plain)

                Button(action: {
                    closeSession()
                }, label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                        Text(L10n.Focus.timerEndSession)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appRed)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.appRed.opacity(0.5), lineWidth: 1)
                    )
                })
                .buttonStyle(.plain)
            }
        }
    }
}
