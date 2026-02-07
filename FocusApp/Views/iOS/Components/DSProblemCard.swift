// LegacyDSProblemCard.swift
// FocusApp — Problem card for coding list (361x72)
// Spec: FIGMA_SETUP_GUIDE.md §3.20

import SwiftUI

struct LegacyDSProblemCard: View {
    var title: String
    var difficulty: LegacyTaskRowDifficulty
    var isSolved: Bool = false

    var body: some View {
        LegacyDSSurfaceCard(padding: DSLayout.spacing(.space16)) {
            HStack {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text(title)
                        .font(LegacyDSTypography.bodyStrong)
                        .foregroundColor(LegacyDSColor.gray900)

                    LegacyDSDifficultyBadge(difficulty: difficulty)
                }

                Spacer()

                // Completion indicator
                if isSolved {
                    ZStack {
                        Circle()
                            .fill(LegacyDSColor.green)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(LegacyDSColor.gray300, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: DSLayout.spacing(.space12)) {
        LegacyDSProblemCard(title: "Two Sum", difficulty: .easy, isSolved: true)
        LegacyDSProblemCard(title: "Add Two Numbers", difficulty: .medium)
        LegacyDSProblemCard(title: "Median of Two Sorted Arrays", difficulty: .hard)
    }
    .padding()
}
