#if os(macOS)
import AppKit
import FocusDesignSystem
import SwiftUI

struct TomorrowProblemRow: View {
    let problem: Problem

    @State private var isHovering = false
    @Environment(\.dsTheme) var theme

    var body: some View {
        HStack(spacing: DSLayout.spacing(8)) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 12))
                .foregroundColor(theme.colors.textSecondary.opacity(0.4))

            DSActionButton(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Text(problem.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.textSecondary)
                    .lineLimit(1)
                    .underline(isHovering)
            })
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
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(difficultyColor.opacity(0.7))
                .padding(.horizontal, DSLayout.spacing(4))
                .padding(.vertical, DSLayout.spacing(1))
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(difficultyColor.opacity(0.12))
                )
        }
        .padding(.horizontal, DSLayout.spacing(8))
        .padding(.vertical, DSLayout.spacing(4))
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovering ? theme.colors.surfaceElevated.opacity(0.2) : Color.clear)
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
#endif
