#if os(iOS)
// iPadFocusView.swift
// FocusApp -- iPad Focus screen (centered timer)
// Wired to FocusCoordinator for live timer state

import FocusDesignSystem
import SwiftUI

struct iPadFocusView: View {
    @ObservedObject var coordinator: FocusCoordinator
    @Environment(\.dsTheme) var theme

    @State private var selectedMinutes: Int = 25

    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let durationOptions = [15, 25, 45, 60, 90, 120, 180]

    private var fp: FocusPresenter { coordinator.presenter }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Title
            VStack(spacing: theme.spacing.sm) {
                Text("Deep Work Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(statusSubtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.colors.textSecondary)
            }

            // Duration picker (only when idle)
            if !fp.hasStarted {
                durationPicker
            }

            // Timer ring
            timerRing

            // Controls
            controlButtons

            // Stats row
            if fp.hasStarted {
                statsRow
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onReceive(timerPublisher) { _ in
            coordinator.handleTick()
        }
    }

    // MARK: - Status

    private var statusSubtitle: String {
        switch coordinator.activeRoute {
        case .idle:
            return "Choose a duration and start focusing."
        case .running:
            return "Stay focused and track your progress."
        case .paused:
            return "Session paused. Resume when ready."
        case .completed:
            return "Session complete! Great work."
        case .selectDuration:
            return "Select your focus duration."
        }
    }

    // MARK: - Duration Picker

    private var durationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(durationOptions, id: \.self) { minutes in
                    Button {
                        selectedMinutes = minutes
                    } label: {
                        Text(formatDuration(minutes))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(
                                selectedMinutes == minutes ? .white : theme.colors.textPrimary
                            )
                            .padding(.horizontal, theme.spacing.lg)
                            .padding(.vertical, theme.spacing.sm)
                            .background(
                                selectedMinutes == minutes
                                    ? theme.colors.primary
                                    : theme.colors.surface
                            )
                            .cornerRadius(theme.radii.pill)
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedMinutes == minutes
                                            ? Color.clear
                                            : theme.colors.border,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.xl)
        }
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        let size: CGFloat = 400
        let progress: CGFloat = fp.hasStarted ? CGFloat(fp.progress) : 0

        return ZStack {
            // Track circle
            Circle()
                .stroke(theme.colors.border, lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)

            // Center text
            VStack(spacing: theme.spacing.xs) {
                Text(fp.hasStarted ? fp.timeString : formatTimerDisplay(selectedMinutes))
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .monospacedDigit()

                Text(timerLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }

    private var ringColor: Color {
        switch coordinator.activeRoute {
        case .completed:
            return theme.colors.success
        case .paused:
            return theme.colors.warning
        default:
            return theme.colors.primary
        }
    }

    private var timerLabel: String {
        switch coordinator.activeRoute {
        case .idle, .selectDuration:
            return "READY"
        case .running:
            return "RUNNING"
        case .paused:
            return "PAUSED"
        case .completed:
            return "COMPLETE"
        }
    }

    private func formatTimerDisplay(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return String(format: "%d:%02d:%02d", hours, mins, 0)
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: theme.spacing.md) {
            switch coordinator.activeRoute {
            case .idle, .selectDuration:
                // Start button
                DSButton(
                    "Start Focus",
                    config: DSButtonConfig(
                        style: .primary,
                        size: .large,
                        icon: Image(systemName: "play.fill")
                    )
                ) {
                    coordinator.startFocusSession(minutes: selectedMinutes)
                }

            case .running:
                // Pause button
                Button {
                    coordinator.pause()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(theme.colors.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // End button
                Button {
                    coordinator.endSession()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.danger)
                        .frame(width: 48, height: 48)
                        .background(theme.colors.surface)
                        .cornerRadius(theme.radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.md)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

            case .paused:
                // Resume button
                Button {
                    coordinator.resume()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(theme.colors.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Reset button
                Button {
                    coordinator.resetSession()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(theme.colors.surface)
                        .cornerRadius(theme.radii.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.radii.md)
                                .stroke(theme.colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

            case .completed:
                // Done / New session button
                DSButton(
                    "New Session",
                    config: DSButtonConfig(
                        style: .primary,
                        size: .large,
                        icon: Image(systemName: "arrow.counterclockwise")
                    )
                ) {
                    coordinator.resetSession()
                }
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 48) {
            VStack(spacing: theme.spacing.xs) {
                Text(fp.timeString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                    .monospacedDigit()
                Text("REMAINING")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                    .kerning(1)
            }

            VStack(spacing: theme.spacing.xs) {
                Text("\(fp.minutesFocused)m")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.colors.textPrimary)
                Text("SESSION")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)
                    .kerning(1)
            }
        }
    }
}
#endif
