#if os(iOS)
// FocusViewiOS.swift
// FocusApp -- Unified adaptive Focus screen for iPhone & iPad
// Uses horizontalSizeClass to switch between compact (iPhone) and regular (iPad) layouts

import FocusDesignSystem
import SwiftUI

// swiftlint:disable:next type_body_length
struct FocusViewiOS: View {
    @ObservedObject var coordinator: FocusCoordinator

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme

    @State private var selectedMinutes: Int = 25

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let durationOptions = [15, 25, 45, 60, 90, 120, 180]

    private var fp: FocusPresenter { coordinator.presenter }

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Text("Focus")
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                // Status badge
                if coordinator.isSessionActive {
                    Text(fp.isPaused ? "Paused" : "Running")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x4B5563))
                        .padding(.horizontal, theme.spacing.md)
                        .padding(.vertical, theme.spacing.xs)
                        .background(Color(hex: 0xF3F4F6))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.sm)

            ScrollView {
                VStack(spacing: theme.spacing.xl) {
                    // Timer card
                    VStack(spacing: theme.spacing.lg) {
                        // Duration picker (only when idle)
                        if !fp.hasStarted {
                            compactDurationPicker
                                .padding(.horizontal, theme.spacing.lg)
                        }

                        // Timer ring
                        timerRing(size: 280, fontSize: 48, useMonospaced: false)
                            .padding(.vertical, theme.spacing.lg)

                        // Buttons
                        compactControlButtons
                    }
                    .padding(theme.spacing.lg)
                    .background(
                        fp.isCompleted
                            ? Color(hex: 0xD1FAE5)
                            : Color(hex: 0xFEE2E2)
                    )
                    .cornerRadius(theme.radii.lg)
                    .padding(.horizontal, theme.spacing.lg)

                    // Current Focus section
                    VStack(spacing: theme.spacing.xs) {
                        Text("CURRENT FOCUS")
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(hex: 0x9CA3AF))
                            .textCase(.uppercase)

                        if fp.isCompleted {
                            Text("Session complete!")
                                .font(theme.typography.body)
                                .foregroundColor(Color(hex: 0x059669))
                                .fontWeight(.semibold)
                        } else if fp.hasStarted {
                            Text(fp.isPaused ? "Session paused" : "Focus time active")
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textPrimary)
                        } else {
                            Text("No active session")
                                .font(theme.typography.body)
                                .foregroundColor(Color(hex: 0x9CA3AF))
                                .italic()
                        }
                    }
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
        .onReceive(timer) { _ in
            coordinator.handleTick()
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
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
                regularDurationPicker
            }

            // Timer ring
            timerRing(size: 400, fontSize: 64, useMonospaced: true)

            // Controls
            regularControlButtons

            // Stats row
            if fp.hasStarted {
                statsRow
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onReceive(timer) { _ in
            coordinator.handleTick()
        }
    }

    // MARK: - Shared: Timer Ring

    private func timerRing(size: CGFloat, fontSize: CGFloat, useMonospaced: Bool) -> some View {
        let progress = fp.hasStarted ? (1.0 - fp.progress) : 0.0
        let color = timerRingColor

        return ZStack {
            // Track circle
            Circle()
                .stroke(Color(hex: 0xE5E7EB), lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)

            // Dot indicator (compact only)
            if !useMonospaced && fp.hasStarted && !fp.isCompleted && progress > 0 {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
            }

            // Center text
            VStack(spacing: theme.spacing.xs) {
                if fp.hasStarted {
                    timerText(fp.timeString, fontSize: fontSize, useMonospaced: useMonospaced)
                } else {
                    let display = useMonospaced
                        ? formatTimerDisplay(selectedMinutes)
                        : formatDuration(selectedMinutes)
                    timerText(display, fontSize: fontSize, useMonospaced: useMonospaced)
                }

                Text(compactStatusLabel)
                    .font(useMonospaced ? .system(size: 12, weight: .semibold) : theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(useMonospaced ? theme.colors.textSecondary : Color(hex: 0x9CA3AF))
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func timerText(_ text: String, fontSize: CGFloat, useMonospaced: Bool) -> some View {
        if useMonospaced {
            Text(text)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(theme.colors.textPrimary)
                .monospacedDigit()
        } else {
            Text(text)
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(theme.colors.textPrimary)
        }
    }

    private var timerRingColor: Color {
        if fp.isCompleted {
            return sizeClass == .regular ? theme.colors.success : Color(hex: 0x059669)
        }
        if sizeClass == .regular {
            if fp.isPaused {
                return theme.colors.warning
            }
            return theme.colors.primary
        }
        // Compact uses danger color when active
        return theme.colors.danger
    }

    // MARK: - Shared: Duration Picker

    private var compactDurationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(durationOptions, id: \.self) { mins in
                    Button {
                        selectedMinutes = mins
                        coordinator.presenter.duration = mins
                    } label: {
                        Text(formatDuration(mins))
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                selectedMinutes == mins
                                    ? .white
                                    : theme.colors.textPrimary
                            )
                            .padding(.horizontal, theme.spacing.md)
                            .frame(height: 36)
                            .background(
                                selectedMinutes == mins
                                    ? Color(hex: 0x6366F1)
                                    : theme.colors.surface
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedMinutes == mins
                                            ? Color.clear
                                            : theme.colors.border,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var regularDurationPicker: some View {
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

    // MARK: - Shared: Formatting

    private func formatDuration(_ minutes: Int) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }

    private func formatTimerDisplay(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return String(format: "%d:%02d:%02d", hours, mins, 0)
    }

    // MARK: - Shared: Status Labels

    private var compactStatusLabel: String {
        if fp.isCompleted { return "COMPLETED" }
        if fp.isPaused { return "PAUSED" }
        if fp.isRunning { return "RUNNING" }
        return "READY"
    }

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

    // MARK: - Compact Controls (iPhone)

    private var compactControlButtons: some View {
        HStack(spacing: theme.spacing.md) {
            if !fp.hasStarted {
                // Start button
                Button {
                    coordinator.startFocusSession(minutes: selectedMinutes)
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        Text("Start")
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.lg)
                    .frame(height: 48)
                    .background(Color(hex: 0x6366F1))
                    .cornerRadius(theme.radii.md)
                }
                .buttonStyle(.plain)
            } else if fp.isCompleted {
                // Session complete - reset
                Button {
                    coordinator.resetSession()
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("Done")
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.spacing.lg)
                    .frame(height: 48)
                    .background(Color(hex: 0x059669))
                    .cornerRadius(theme.radii.md)
                }
                .buttonStyle(.plain)
            } else {
                // Pause/Resume button
                Button {
                    if fp.isPaused {
                        coordinator.resume()
                    } else {
                        coordinator.pause()
                    }
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: fp.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16))
                        Text(fp.isPaused ? "Resume" : "Pause")
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

                // End session button
                Button {
                    coordinator.endSession()
                } label: {
                    Image(systemName: "stop.fill")
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
    }

    // MARK: - Regular Controls (iPad)

    private var regularControlButtons: some View {
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

    // MARK: - Stats Row (iPad only)

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
