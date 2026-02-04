import AppKit
import SwiftUI

struct HabitToggle: View {
    let label: String
    let icon: String
    let done: Bool
    let onToggle: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Image(systemName: done ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 11))
                    .foregroundColor(done ? .green : .gray)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(done ? .green : .gray)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(done ? Color.green.opacity(0.18) : Color.white.opacity(isHovering ? 0.12 : 0.06))
            )
            .overlay(
                Capsule()
                    .stroke(done ? Color.green.opacity(0.35) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}
