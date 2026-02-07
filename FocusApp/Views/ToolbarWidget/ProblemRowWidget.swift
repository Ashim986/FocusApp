import AppKit
import FocusDesignSystem
import SwiftUI

struct ProblemRowWidget: View {
    let problem: Problem
    let isCompleted: Bool
    let onRefresh: () -> Void

    @State private var isHovering = false
    @Environment(\.dsTheme) var theme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isCompleted ? theme.colors.success : theme.colors.textSecondary.opacity(0.5))

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Text(problem.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(
                        isCompleted
                            ? theme.colors.textSecondary.opacity(0.85)
                            : theme.colors.textPrimary.opacity(0.9)
                    )
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

            Text(problem.difficulty.rawValue)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(difficultyColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(difficultyColor.opacity(0.2))
                )

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.primary.opacity(0.7))
            })
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated.opacity(isHovering ? 0.25 : 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.colors.border.opacity(0.35), lineWidth: 1)
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
