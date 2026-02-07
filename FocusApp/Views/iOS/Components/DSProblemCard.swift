// DSProblemCard.swift
// FocusApp — Problem card for coding list (361x72)
// Spec: FIGMA_SETUP_GUIDE.md §3.20

import SwiftUI

struct DSProblemCard: View {
    var title: String
    var difficulty: TaskRowDifficulty
    var isSolved: Bool = false

    var body: some View {
        DSSurfaceCard(padding: DSSpacing.space16) {
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.space4) {
                    Text(title)
                        .font(DSTypography.bodyStrong)
                        .foregroundColor(DSColor.gray900)

                    DSDifficultyBadge(difficulty: difficulty)
                }

                Spacer()

                // Completion indicator
                if isSolved {
                    ZStack {
                        Circle()
                            .fill(DSColor.green)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(DSColor.gray300, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.space12) {
        DSProblemCard(title: "Two Sum", difficulty: .easy, isSolved: true)
        DSProblemCard(title: "Add Two Numbers", difficulty: .medium)
        DSProblemCard(title: "Median of Two Sorted Arrays", difficulty: .hard)
    }
    .padding()
}
