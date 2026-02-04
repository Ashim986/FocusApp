import SwiftUI

extension TodayView {
    var focusCTACard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to Focus?")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text("Block distractions and start your study session")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                HStack(spacing: 8) {
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

                    Button(action: {
                        showFocusMode = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text("Start Focus")
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
            }

            Divider()
                .background(Color.white.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                Text("Sites blocked during focus:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                FlowLayout(spacing: 6) {
                    ForEach(blockedSites, id: \.self) { site in
                        Text(site)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
            }
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
