import AppKit
import FocusDesignSystem
import SwiftUI

struct CarryoverProblemRow: View {
    let problem: Problem
    let onToggle: () -> Void

    @State private var isHovering = false
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            DSButton(action: onToggle, label: {
                DSImage(systemName: "circle")
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.warning.opacity(0.7))
            })
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            DSButton(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                DSText(problem.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.warning.opacity(0.9))
                    .lineLimit(1)
                    .underline(isHovering)
            })
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()

            DSText(problem.difficulty.rawValue)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(difficultyColor)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(difficultyColor.opacity(0.2))
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(theme.colors.warning.opacity(isHovering ? 0.16 : 0.1))
        )
    }

    private var difficultyColor: Color {
        switch problem.difficulty {
        case .easy:
            return theme.colors.success
        case .medium:
            return theme.colors.warning
        case .hard:
            return theme.colors.danger
        }
    }
}
