#if os(iOS)
// iPhoneFocusView.swift
// FocusApp -- iPhone Focus (Pomodoro) screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneFocusView: View {
    @Environment(\.dsTheme) var theme

    @ObservedObject var coordinator: FocusCoordinator

    private var fp: FocusPresenter { coordinator.presenter }

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
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
                            durationPicker
                                .padding(.horizontal, theme.spacing.lg)
                        }

                        // Timer ring
                        timerRing
                            .padding(.vertical, theme.spacing.lg)

                        // Buttons
                        HStack(spacing: theme.spacing.md) {
                            if !fp.hasStarted {
                                // Start button
                                Button {
                                    coordinator.startFocusSession(minutes: fp.duration)
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

    // MARK: - Duration Picker

    private var durationPicker: some View {
        let durations = [15, 25, 45, 60, 90, 120, 180]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                ForEach(durations, id: \.self) { mins in
                    Button {
                        coordinator.presenter.duration = mins
                    } label: {
                        Text(durationLabel(mins))
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                fp.duration == mins
                                    ? .white
                                    : theme.colors.textPrimary
                            )
                            .padding(.horizontal, theme.spacing.md)
                            .frame(height: 36)
                            .background(
                                fp.duration == mins
                                    ? Color(hex: 0x6366F1)
                                    : theme.colors.surface
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        fp.duration == mins
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

    private func durationLabel(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        let size: CGFloat = 280
        let ringColor: Color = fp.isCompleted
            ? Color(hex: 0x059669)
            : theme.colors.danger
        let progress = fp.hasStarted ? (1.0 - fp.progress) : 0.0

        return ZStack {
            // Track circle
            Circle()
                .stroke(Color(hex: 0xE5E7EB), lineWidth: 8)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Dot indicator
            if fp.hasStarted && !fp.isCompleted && progress > 0 {
                Circle()
                    .fill(ringColor)
                    .frame(width: 12, height: 12)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(360 * progress - 90))
            }

            // Center text
            VStack(spacing: theme.spacing.xs) {
                if fp.hasStarted {
                    Text(fp.timeString)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(theme.colors.textPrimary)
                } else {
                    Text(durationLabel(fp.duration))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(theme.colors.textPrimary)
                }

                Text(statusLabel)
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .kerning(2)
            }
        }
        .frame(width: size, height: size)
    }

    private var statusLabel: String {
        if fp.isCompleted { return "COMPLETED" }
        if fp.isPaused { return "PAUSED" }
        if fp.isRunning { return "RUNNING" }
        return "READY"
    }
}
#endif
