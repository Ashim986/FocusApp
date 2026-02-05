import AppKit
import SwiftUI

struct TomorrowProblemRow: View {
    let problem: Problem

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.4))

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Text(problem.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
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
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(problem.difficulty == .easy ? .green.opacity(0.6) : .orange.opacity(0.6))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.1))
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovering ? Color.white.opacity(0.05) : Color.clear)
        )
    }
}
