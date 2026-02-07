// iPhoneFocusView.swift
// FocusApp -- iPhone Focus (Pomodoro) screen (393x852)

import FocusDesignSystem
import SwiftUI

// MARK: - Pomodoro Segment

enum PomodoroSegment: String, CaseIterable {
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
}

struct iPhoneFocusView: View {
    @Environment(\.dsTheme) var theme

    @State private var selectedSegment: PomodoroSegment = .focus
    @State private var isRunning = false
    @State private var progress: Double = 0.0
    @State private var sessionCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Text("Focus")
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                // Sessions badge
                Text("Sessions: \(sessionCount)")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x4B5563))
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.xs)
                    .background(Color(hex: 0xF3F4F6))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.sm)

            ScrollView {
                VStack(spacing: theme.spacing.xl) {
                    // Timer card
                    VStack(spacing: theme.spacing.lg) {
                        // Segmented control
                        pomodoroSegmentedControl
                            .padding(.horizontal, theme.spacing.lg)

                        // Timer ring
                        timerRing
                            .padding(.vertical, theme.spacing.lg)

                        // Buttons
                        HStack(spacing: theme.spacing.md) {
                            // Start/Pause button
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
                                .padding(.horizontal, theme.spacing.lg)
                                .frame(height: 48)
                                .background(theme.colors.danger)
                                .cornerRadius(theme.radii.md)
                            }
                            .buttonStyle(.plain)

                            // Reset button
                            Button {
                                isRunning = false
                                progress = 0
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
                    }
                    .padding(theme.spacing.lg)
                    .background(Color(hex: 0xFEE2E2))
                    .cornerRadius(theme.radii.lg)
                    .padding(.horizontal, theme.spacing.lg)

                    // Current Focus section
                    VStack(spacing: theme.spacing.xs) {
                        Text("CURRENT FOCUS")
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x9CA3AF))
                            .textCase(.uppercase)

                        Text("No active tasks")
                            .font(theme.typography.body)
                            .foregroundColor(Color(hex: 0x9CA3AF))
                            .italic()
                    }

                    // Tasks card
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("Tasks 0")
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.colors.textPrimary)

                        Text("No tasks linked to this session")
                            .font(theme.typography.body)
                            .foregroundColor(Color(hex: 0x9CA3AF))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(theme.spacing.lg)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Pomodoro Segmented Control

    private var pomodoroSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(PomodoroSegment.allCases, id: \.self) { segment in
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
                            : Color(hex: 0x6B7280)
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        selectedSegment == segment
                            ? theme.colors.surface
                                .shadow(.drop(color: .black.opacity(0.05), radius: 3, y: 1))
                            : Color.clear
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(theme.spacing.xs)
        .background(Color(hex: 0xF3F4F6))
        .clipShape(Capsule())
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        let size: CGFloat = 280
        let ringColor = theme.colors.danger

        return ZStack {
            // Track circle
            Circle()
                .stroke(Color(hex: 0xE5E7EB), lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: isRunning ? 0.004 : 0.0)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Dot indicator
            if isRunning {
                Circle()
                    .fill(ringColor)
                    .frame(width: 12, height: 12)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * 0.004 - 90))
            }

            // Center text
            VStack(spacing: theme.spacing.xs) {
                Text(isRunning ? "24:54" : "25:00")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(isRunning ? "RUNNING" : "PAUSED")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    iPhoneFocusView()
}
