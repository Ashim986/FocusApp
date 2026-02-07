// iPadFocusView.swift
// FocusApp — iPad Focus screen (centered timer)
// Spec: FIGMA_SETUP_GUIDE.md §5.4

import FocusDesignSystem
import SwiftUI

struct iPadFocusView: View {
    @Environment(\.dsTheme) var theme
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Title
            VStack(spacing: theme.spacing.sm) {
                Text("Deep Work Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text("Stay focused and track your progress.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            // Timer ring (400px on iPad)
            timerRing

            // Controls
            HStack(spacing: theme.spacing.md) {
                // Play/Pause button
                Button {
                    isRunning.toggle()
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: 0x6366F1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Reset button
                Button {
                    isRunning = false
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: 0x6B7280))
                        .frame(width: 48, height: 48)
                        .background(theme.colors.surface)
                        .cornerRadius(theme.radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.md)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            // Stats row
            HStack(spacing: 48) {
                VStack(spacing: theme.spacing.xs) {
                    Text("3")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.colors.textPrimary)
                    Text("SESSIONS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: 0x9CA3AF))
                        .kerning(1)
                }

                VStack(spacing: theme.spacing.xs) {
                    Text("75m")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.colors.textPrimary)
                    Text("TOTAL FOCUS")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: 0x9CA3AF))
                        .kerning(1)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        let size: CGFloat = 400

        return ZStack {
            // Track circle
            Circle()
                .stroke(theme.colors.border, lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc (no progress yet)
            Circle()
                .trim(from: 0, to: 0)
                .stroke(
                    Color(hex: 0x6366F1),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Center text
            VStack(spacing: theme.spacing.xs) {
                Text("25:00")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(isRunning ? "RUNNING" : "PAUSED")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    iPadFocusView()
        .frame(width: 574, height: 1194)
}
