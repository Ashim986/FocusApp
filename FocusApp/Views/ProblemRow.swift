import SwiftUI

struct ProblemRow: View {
    let problem: Problem
    let isCompleted: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(isCompleted ? Color.appGreen : Color.appGray300, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isCompleted ? Color.appGreen : Color.clear)
                        )

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            })
            .buttonStyle(.plain)

            // Problem name (clickable)
            Button(action: onSelect, label: {
                HStack(spacing: 4) {
                    Text(problem.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(isCompleted ? Color.appGray500 : Color.appGray700)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(1)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color.appGray500)
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
            Text(problem.difficulty.rawValue)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(problem.difficulty == .easy ? Color.appGreenLight : Color.appAmberLight)
                )
                .foregroundColor(problem.difficulty == .easy ? Color.appGreen : Color.appAmber)
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
