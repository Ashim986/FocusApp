import AppKit
import SwiftUI

struct CarryoverProblemRow: View {
    let problem: Problem
    let onToggle: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle, label: {
                Image(systemName: "circle")
                    .font(.system(size: 12))
                    .foregroundColor(.orange.opacity(0.6))
            })
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }, label: {
                Text(problem.name)
                    .font(.system(size: 10))
                    .foregroundColor(.orange.opacity(0.9))
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
                .foregroundColor(problem.difficulty == .easy ? .green : .orange)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.2))
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.orange.opacity(isHovering ? 0.15 : 0.08))
        )
    }
}
