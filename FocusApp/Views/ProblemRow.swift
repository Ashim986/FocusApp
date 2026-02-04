import SwiftUI

struct ProblemRow: View {
    let problem: Problem
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
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
            }
            .buttonStyle(.plain)

            // Problem name (clickable)
            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text(problem.name)
                    .font(.system(size: 14))
                    .foregroundColor(isCompleted ? Color.appGray400 : Color.appGray700)
                    .strikethrough(isCompleted, color: Color.appGray400)
            }
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
                onToggle: {}
            )
            ProblemRow(
                problem: Problem(name: "3Sum", difficulty: .medium, url: "https://leetcode.com"),
                isCompleted: true,
                onToggle: {}
            )
        }
        .padding()
        .frame(width: 400)
    }
}
#endif
