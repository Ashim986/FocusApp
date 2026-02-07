// MacFocusView.swift
// FocusApp -- Mac Focus screen (centered timer)

import FocusDesignSystem
import SwiftUI

struct MacFocusView: View {
    @Environment(\.dsTheme) var theme

    @State private var selectedSegment: MacPomodoroSegment = .focus
    @State private var isRunning = false
    @State private var progress: CGFloat = 0.0

    var body: some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Title
            VStack(spacing: theme.spacing.sm) {
                Text("Deep Work Session")
                    .font(theme.typography.title)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Stay focused and track your progress.")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
            }

            // Segmented control
            macPomodoroSegmentedControl

            // Timer ring
            macTimerRing

            // Controls
            HStack(spacing: theme.spacing.md) {
                // Start / Pause button
                Button {
                    isRunning.toggle()
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 16))
                        Text(isRunning ? "Pause" : "Start")
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .frame(height: 44)
                    .background(Color(hex: 0x6366F1))
                    .cornerRadius(theme.radii.md)
                }
                .buttonStyle(.plain)

                // Reset button
                Button {
                    isRunning = false
                    progress = 0.0
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14))
                        Text("Reset")
                            .font(theme.typography.body)
                    }
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, 24)
                    .frame(height: 44)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // Session stats row
            HStack(spacing: 48) {
                VStack(spacing: theme.spacing.xs) {
                    Text("3")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                    Text("SESSIONS")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textSecondary)
                        .kerning(1)
                }

                VStack(spacing: theme.spacing.xs) {
                    Text("75m")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                    Text("TOTAL FOCUS")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textSecondary)
                        .kerning(1)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(theme.colors.background)
    }

    // MARK: - Pomodoro Segmented Control

    private var macPomodoroSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(MacPomodoroSegment.allCases, id: \.self) { segment in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSegment = segment
                    }
                } label: {
                    HStack(spacing: theme.spacing.xs) {
                        Image(systemName: segment.iconName)
                            .font(.system(size: 14))
                        Text(segment.rawValue)
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(
                        selectedSegment == segment
                            ? theme.colors.textPrimary
                            : theme.colors.textSecondary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(
                        selectedSegment == segment
                            ? theme.colors.surface
                            : Color.clear
                    )
                    .clipShape(Capsule())
                    .shadow(
                        color: selectedSegment == segment
                            ? .black.opacity(0.05)
                            : .clear,
                        radius: 3,
                        y: 1
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(theme.spacing.xs)
        .background(theme.colors.surfaceElevated)
        .clipShape(Capsule())
        .frame(maxWidth: 400)
    }

    // MARK: - Timer Ring

    private var macTimerRing: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(theme.colors.border.opacity(0.3), lineWidth: 8)
                .frame(width: 360, height: 360)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: 0x6366F1),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 360, height: 360)

            // Center content
            VStack(spacing: theme.spacing.sm) {
                Text(selectedSegment.timeDisplay)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(theme.colors.textPrimary)
                    .monospacedDigit()

                Text(isRunning ? "RUNNING" : "PAUSED")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        isRunning
                            ? Color(hex: 0x6366F1)
                            : theme.colors.textSecondary
                    )
                    .kerning(2)
            }
        }
    }
}

// MARK: - Pomodoro Segment

private enum MacPomodoroSegment: String, CaseIterable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var iconName: String {
        switch self {
        case .focus: return "scope"
        case .shortBreak: return "cup.and.saucer"
        case .longBreak: return "moon"
        }
    }

    var timeDisplay: String {
        switch self {
        case .focus: return "25:00"
        case .shortBreak: return "05:00"
        case .longBreak: return "15:00"
        }
    }
}

#Preview("Mac Focus") {
    MacFocusView()
        .frame(width: 1200, height: 760)
}
