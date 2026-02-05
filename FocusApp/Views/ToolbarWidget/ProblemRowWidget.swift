import AppKit
import SwiftUI

struct ProblemRowWidget: View {
    let problem: Problem
    let isCompleted: Bool
    let onRefresh: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isCompleted ? .green : .gray.opacity(0.5))

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Text(problem.displayName)
                    .font(.system(size: 11))
                    .foregroundColor(isCompleted ? .gray : .white.opacity(0.9))
                    .strikethrough(isCompleted, color: .gray)
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
                .foregroundColor(problem.difficulty == .easy ? .green : .orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.2))
                )

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 10))
                    .foregroundColor(.blue.opacity(0.7))
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
                .fill(Color.white.opacity(isHovering ? 0.08 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
