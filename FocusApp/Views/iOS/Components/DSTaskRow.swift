// LegacyDSTaskRow.swift
// FocusApp — Task row (361x56)
// Spec: FIGMA_SETUP_GUIDE.md §3.8

import SwiftUI

enum LegacyTaskRowDifficulty: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var bgColor: Color {
        switch self {
        case .easy: return LegacyDSColor.easyBg
        case .medium: return LegacyDSColor.mediumBg
        case .hard: return LegacyDSColor.hardBg
        }
    }

    var textColor: Color {
        switch self {
        case .easy: return LegacyDSColor.easyText
        case .medium: return LegacyDSColor.mediumText
        case .hard: return LegacyDSColor.hardText
        }
    }
}

struct LegacyDSTaskRow: View {
    var title: String
    var subtitle: String?
    var isCompleted: Bool = false
    var difficulty: LegacyTaskRowDifficulty?
    var progressText: String? // e.g. "1/4" for habit rows

    var body: some View {
        HStack(spacing: DSLayout.spacing(.space12)) {
            // Check icon
            if isCompleted {
                ZStack {
                    Circle()
                        .fill(LegacyDSColor.purple)
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Circle()
                    .strokeBorder(LegacyDSColor.gray300, style: StrokeStyle(lineWidth: 1.5, dash: [3]))
                    .frame(width: 24, height: 24)
            }

            // Title + Subtitle
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                Text(title)
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(isCompleted ? LegacyDSColor.gray400 : LegacyDSColor.gray900)
                    .strikethrough(isCompleted)

                if let subtitle {
                    Text(subtitle)
                        .font(LegacyDSTypography.caption)
                        .foregroundColor(LegacyDSColor.gray500)
                }
            }

            Spacer()

            // Progress text or difficulty badge
            if let progressText {
                Text(progressText)
                    .font(LegacyDSTypography.subbodyStrong)
                    .foregroundColor(LegacyDSColor.gray500)
            }

            if let difficulty {
                LegacyDSDifficultyBadge(difficulty: difficulty)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(LegacyDSColor.gray400)
        }
        .padding(.horizontal, DSLayout.spacing(.space16))
        .frame(height: 56)
    }
}

struct LegacyDSDifficultyBadge: View {
    var difficulty: LegacyTaskRowDifficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(LegacyDSTypography.captionStrong)
            .foregroundColor(difficulty.textColor)
            .padding(.horizontal, DSLayout.spacing(.space8))
            .padding(.vertical, DSLayout.spacing(.space4))
            .background(difficulty.bgColor)
            .cornerRadius(LegacyDSRadius.small)
    }
}

#Preview {
    VStack(spacing: 0) {
        LegacyDSTaskRow(
            title: "Complete Two Sum",
            subtitle: "Arrays & Hashing - LeetCode 75",
            isCompleted: true,
            difficulty: .easy
        )
        Divider()
        LegacyDSTaskRow(
            title: "Read System Design Chapter 5",
            subtitle: "System Design",
            isCompleted: false
        )
        Divider()
        LegacyDSTaskRow(
            title: "Exercise",
            isCompleted: true,
            progressText: "1/4"
        )
    }
}
