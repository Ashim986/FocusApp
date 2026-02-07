import AppKit
import FocusDesignSystem
import SwiftUI

struct HabitToggle: View {
    let label: String
    let icon: String
    let done: Bool
    let onToggle: () -> Void

    @State private var isHovering = false
    @Environment(\.dsTheme) var theme

    var body: some View {
        DSButton(action: onToggle) {
            HStack(spacing: 4) {
                DSImage(systemName: done ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 11))
                    .foregroundColor(done ? theme.colors.success : theme.colors.textSecondary)

                DSText(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(done ? theme.colors.success : theme.colors.textSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        done
                            ? theme.colors.success.opacity(0.18)
                            : theme.colors.surfaceElevated.opacity(isHovering ? 0.35 : 0.2)
                    )
            )
            .overlay(
                Capsule()
                    .stroke(
                        done
                            ? theme.colors.success.opacity(0.35)
                            : theme.colors.border.opacity(0.3),
                        lineWidth: 1
                    )
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
