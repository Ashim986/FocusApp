import SwiftUI

#if os(macOS)
import FocusDesignSystem

struct ProblemRow: View {
    let problem: Problem
    let isCompleted: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void
    @Environment(\.dsTheme) var theme

    var body: some View {
        HStack(spacing: DSLayout.spacing(12)) {
            // Checkbox
            DSActionButton(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isCompleted ? theme.colors.success : Color.clear)
                        )

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            // Problem name (clickable)
            DSActionButton(action: onSelect) {
                HStack(spacing: DSLayout.spacing(4)) {
                    Text(problem.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()

            // Difficulty badge
            DSBadge(
                problem.difficulty.rawValue,
                config: .init(style: problem.difficulty == .easy ? .success : .warning)
            )
        }
        .padding(.vertical, DSLayout.spacing(8))
        .padding(.horizontal, DSLayout.spacing(12))
    }
}

#if DEBUG
struct ProblemRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProblemRow(
                problem: Problem(name: "Two Sum", difficulty: .easy, url: "https://leetcode.com"),
                isCompleted: false,
                onToggle: {},
                onSelect: {}
            )
            ProblemRow(
                problem: Problem(name: "3Sum", difficulty: .medium, url: "https://leetcode.com"),
                isCompleted: true,
                onToggle: {},
                onSelect: {}
            )
        }
        .padding()
        .frame(width: 400)
    }
}
#endif

#endif
