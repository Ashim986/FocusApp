import FocusDesignSystem
import SwiftUI

struct ProblemRow: View {
    let problem: Problem
    let isCompleted: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void
    @Environment(\.dsTheme) var theme

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            DSButton(action: onToggle, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isCompleted ? theme.colors.success : Color.clear)
                        )

                    if isCompleted {
                        DSImage(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            })
            .buttonStyle(.plain)

            // Problem name (clickable)
            DSButton(action: onSelect, label: {
                HStack(spacing: 4) {
                    DSText(problem.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(isCompleted ? theme.colors.textSecondary : theme.colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)

                    DSImage(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
            })
            .buttonStyle(.plain)
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
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
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
