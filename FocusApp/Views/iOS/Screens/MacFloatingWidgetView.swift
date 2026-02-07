// MacFloatingWidgetView.swift
// FocusApp — Mac Floating Widget (350x560)
// Always-on-top NSPanel for quick access

import FocusDesignSystem
import SwiftUI

struct MacFloatingWidgetView: View {
    @Environment(\.dsTheme) var theme

    @State private var showSettings = false
    @State private var showTomorrow = false
    @State private var isSyncing = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Text("FocusApp")
                    .font(theme.typography.subtitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                // Sync button
                Button {
                    isSyncing = true
                } label: {
                    Image(systemName: isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                        .rotationEffect(.degrees(isSyncing ? 360 : 0))
                }
                .buttonStyle(.plain)

                // Settings button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                    }
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
            .background(theme.colors.surface)

            Divider()

            // MARK: - Settings Panel (collapsible)
            if showSettings {
                VStack(spacing: theme.spacing.sm) {
                    Text("LeetCode Username")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: theme.spacing.sm) {
                        TextField("Username", text: .constant("ashim986"))
                            .textFieldStyle(.roundedBorder)
                            .font(theme.typography.body)

                        Button("Save & Sync") { }
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.vertical, theme.spacing.xs)
                            .background(Color(hex: 0x6366F1))
                            .cornerRadius(theme.radii.sm)
                    }
                }
                .padding(theme.spacing.md)
                .background(theme.colors.surfaceElevated)

                Divider()
            }

            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    // Progress Section
                    progressSection

                    Divider().padding(.horizontal, theme.spacing.lg)

                    // Problem List
                    problemListSection

                    Divider().padding(.horizontal, theme.spacing.lg)

                    // Habits
                    habitsSection

                    Divider().padding(.horizontal, theme.spacing.lg)

                    // Tomorrow (collapsible)
                    tomorrowSection

                    // Advance Button
                    advanceButton
                }
                .padding(.vertical, theme.spacing.md)
            }
        }
        .frame(width: 350, height: 560)
        .background(theme.colors.background)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        HStack(spacing: theme.spacing.lg) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(theme.colors.border, lineWidth: 4)
                    .frame(width: 56, height: 56)

                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(Color(hex: 0x6366F1), lineWidth: 4)
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))

                Text("60%")
                    .font(theme.typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(theme.colors.textPrimary)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Day 5 — Sliding Window")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("3/5 problems solved")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)

                Text("Habits: 2/3")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
    }

    // MARK: - Problem List

    private var problemListSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Today's Problems")
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, theme.spacing.lg)

            VStack(spacing: 0) {
                widgetProblemRow(title: "Best Time to Buy Stock", isSolved: true, difficulty: "Easy")
                Divider().padding(.leading, 40)
                widgetProblemRow(title: "Longest Substring", isSolved: true, difficulty: "Medium")
                Divider().padding(.leading, 40)
                widgetProblemRow(title: "Min Window Substring", isSolved: false, difficulty: "Hard")
                Divider().padding(.leading, 40)
                widgetProblemRow(title: "Sliding Window Maximum", isSolved: false, difficulty: "Hard")
                Divider().padding(.leading, 40)
                widgetProblemRow(title: "Permutation in String", isSolved: true, difficulty: "Medium")
            }
        }
    }

    private func widgetProblemRow(title: String, isSolved: Bool, difficulty: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            if isSolved {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(theme.colors.success)
            } else {
                Circle()
                    .strokeBorder(Color(hex: 0xD1D5DB), lineWidth: 1.5)
                    .frame(width: 16, height: 16)
            }

            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(isSolved ? theme.colors.textSecondary : theme.colors.textPrimary)
                .strikethrough(isSolved)
                .lineLimit(1)

            Spacer()

            Text(difficulty)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(difficultyTextColor(difficulty))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(difficultyBgColor(difficulty))
                .cornerRadius(4)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, 6)
    }

    // MARK: - Habits

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Habits")
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, theme.spacing.lg)

            HStack(spacing: theme.spacing.sm) {
                habitToggle(label: "DSA", isOn: true)
                habitToggle(label: "Exercise", isOn: true)
                habitToggle(label: "Other", isOn: false)
            }
            .padding(.horizontal, theme.spacing.lg)
        }
    }

    private func habitToggle(label: String, isOn: Bool) -> some View {
        Button { } label: {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(isOn ? Color(hex: 0x6366F1) : Color(hex: 0x9CA3AF))

                Text(label)
                    .font(theme.typography.caption)
                    .foregroundColor(isOn ? theme.colors.textPrimary : theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(isOn ? Color(hex: 0x6366F1).opacity(0.08) : theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tomorrow Section

    private var tomorrowSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                withAnimation { showTomorrow.toggle() }
            } label: {
                HStack {
                    Text("Tomorrow — Binary Search")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x3B82F6))

                    Text("(2 carryover)")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: 0xF97316))

                    Spacer()

                    Image(systemName: showTomorrow ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, theme.spacing.lg)

            if showTomorrow {
                VStack(spacing: 0) {
                    // Carryover items (orange)
                    carryoverRow(title: "Min Window Substring")
                    Divider().padding(.leading, 40)
                    carryoverRow(title: "Sliding Window Maximum")
                    Divider().padding(.leading, 40)
                    // Tomorrow items (muted)
                    tomorrowRow(title: "Binary Search")
                    Divider().padding(.leading, 40)
                    tomorrowRow(title: "Search in Rotated Array")
                }
            }
        }
    }

    private func carryoverRow(title: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Circle()
                .strokeBorder(Color(hex: 0xF97316), lineWidth: 1.5)
                .frame(width: 14, height: 14)

            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(Color(hex: 0xF97316))
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, 5)
    }

    private func tomorrowRow(title: String) -> some View {
        HStack(spacing: theme.spacing.sm) {
            Circle()
                .strokeBorder(Color(hex: 0xD1D5DB), style: StrokeStyle(lineWidth: 1, dash: [2]))
                .frame(width: 14, height: 14)

            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, 5)
    }

    // MARK: - Advance Button

    private var advanceButton: some View {
        Group {
            // Only show when all problems solved (placeholder)
            EmptyView()
        }
    }

    // MARK: - Helpers

    private func difficultyTextColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return Color(hex: 0x059669)
        case "Medium": return Color(hex: 0xD97706)
        case "Hard": return Color(hex: 0xDC2626)
        default: return theme.colors.textSecondary
        }
    }

    private func difficultyBgColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return Color(hex: 0xD1FAE5)
        case "Medium": return Color(hex: 0xFEF3C7)
        case "Hard": return Color(hex: 0xFEE2E2)
        default: return theme.colors.surfaceElevated
        }
    }
}

#Preview {
    MacFloatingWidgetView()
}
