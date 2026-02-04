import SwiftUI

extension TodayView {
    var codingCTACard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to Code?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Jump into the editor and start your next problem.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Button(action: {
                    showCodeEnvironment = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left.slash.chevron.right")
                        Text("Start Coding")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.appPurple)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                    )
                }
                .buttonStyle(.plain)
            }

            Text("A 30-minute focus timer starts automatically for each problem.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.appIndigo, Color.appIndigoLight],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}
