// LegacyDSDailyGoalCard.swift
// FocusApp — Purple gradient daily goal card (361x140)
// Spec: FIGMA_SETUP_GUIDE.md §3.5

import SwiftUI

struct LegacyDSDailyGoalCard: View {
    var completed: Int = 1
    var total: Int = 4

    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
            // Row 1: Icon + Label
            HStack {
                // Target icon in circle
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "target")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                Text("Daily Goal")
                    .font(LegacyDSTypography.subbodyStrong)
                    .foregroundColor(.white)

                Spacer()
            }

            // Row 2: Progress count
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                Text("\(completed)/\(total)")
                    .font(LegacyDSTypography.title)
                    .foregroundColor(.white)

                Text("Tasks completed")
                    .font(LegacyDSTypography.subbody)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Row 3: Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 6)

                    // Fill
                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width: total > 0
                                ? geo.size.width * CGFloat(completed) / CGFloat(total)
                                : 0,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
        .padding(DSLayout.spacing(20))
        .frame(height: 140)
        .background(LegacyDSColor.purpleGradient)
        .cornerRadius(LegacyDSRadius.large)
    }
}

#Preview {
    LegacyDSDailyGoalCard()
        .padding()
}
