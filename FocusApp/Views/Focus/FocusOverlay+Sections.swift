import SwiftUI

extension FocusOverlay {
    var durationSelector: some View {
        VStack(spacing: 40) {
            VStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color.appPurple)

                Text("Focus Mode")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("How long do you want to focus?")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    durationButton(minutes: 30)
                    durationButton(minutes: 60)
                    durationButton(minutes: 90)
                }

                HStack(spacing: 20) {
                    durationButton(minutes: 120)
                    durationButton(minutes: 180)
                    durationButton(minutes: 240)
                }
            }

            HStack(spacing: 12) {
                Text("Custom:")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))

                TextField("", value: $presenter.duration, format: .number)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )

                Text("minutes")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            Button(action: presenter.startTimer) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Start Focus Session")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appPurple)
                )
            }
            .buttonStyle(.plain)

            Button(action: { closeSession() }) {
                Text("Cancel")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    func durationButton(minutes: Int) -> some View {
        Button(action: { presenter.duration = minutes }) {
            Text("\(minutes) min")
                .font(.system(size: 14, weight: presenter.duration == minutes ? .semibold : .regular))
                .foregroundColor(presenter.duration == minutes ? Color.appPurple : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(presenter.duration == minutes ? Color.white : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}
