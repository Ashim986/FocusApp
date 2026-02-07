// DSTaskRow.swift
// FocusApp — Task row (361x56)
// Spec: FIGMA_SETUP_GUIDE.md §3.8

import SwiftUI

enum TaskRowDifficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var bgColor: Color {
        switch self {
        case .easy: return DSColor.easyBg
        case .medium: return DSColor.mediumBg
        case .hard: return DSColor.hardBg
        }
    }

    var textColor: Color {
        switch self {
        case .easy: return DSColor.easyText
        case .medium: return DSColor.mediumText
        case .hard: return DSColor.hardText
        }
    }
}

struct DSTaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: TaskRowDifficulty?
    var progressText: String? // e.g. "1/4" for habit rows

    var body: some View {
        HStack(spacing: DSSpacing.space12) {
            // Check icon
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(DSColor.purple)
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Circle()
                    .strokeBorder(DSColor.gray300, style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                    .frame(width: 24, height: 24)
            }

            // Title + Subtitle
            VStack(alignment: .leading, spacing: DSSpacing.space2) {
                Text(title)
                    .font(DSTypography.bodyStrong)
                    .foregroundColor(isCompleted ? DSColor.gray400 : DSColor.gray900)
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.gray500)
                }
            }

            Spacer()

            // Progress text or difficulty badge
            if let progressText {
                Text(progressText)
                    .font(DSTypography.subbodyStrong)
                    .foregroundColor(DSColor.gray500)
            }

            if let difficulty {
                DSDifficultyBadge(difficulty: difficulty)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(DSColor.gray400)
        }
        .padding(.horizontal, DSSpacing.space16)
        .frame(height: 56)
    }
}

struct DSDifficultyBadge: View {
    var difficulty: TaskRowDifficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(DSTypography.captionStrong)
            .foregroundColor(difficulty.textColor)
            .padding(.horizontal, DSSpacing.space8)
            .padding(.vertical, DSSpacing.space4)
            .background(difficulty.bgColor)
            .cornerRadius(DSRadius.small)
    }
}

#Preview {
    VStack(spacing: 0) {
        DSTaskRow(
            title: "Complete Two Sum",
            subtitle: "Arrays & Hashing - LeetCode 75",
            isCompleted: true,
            difficulty: .easy
        )
        Divider()
        DSTaskRow(
            title: "Read System Design Chapter 5",
            subtitle: "System Design",
            isCompleted: false
        )
        Divider()
        DSTaskRow(
            title: "Exercise",
            isCompleted: true,
            progressText: "1/4"
        )
    }
}
