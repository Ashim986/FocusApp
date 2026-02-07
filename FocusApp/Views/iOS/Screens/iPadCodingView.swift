// iPadCodingView.swift
// FocusApp — iPad Coding Environment (three-panel layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.5

import FocusDesignSystem
import SwiftUI

struct iPadCodingView: View {
    @Environment(\.dsTheme) var theme
    @State private var searchText = ""
    @State private var selectedProblem: String?

    var body: some View {
        HStack(spacing: 0) {
            // Left panel: Problem list (220px)
            problemListPanel

            // Center panel: Content area
            contentPanel

            // Right panel: Output (140px)
            outputPanel
        }
    }

    // MARK: - Problem List Panel

    private var problemListPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Coding Environment")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(theme.spacing.md)

            // Search bar
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x9CA3AF))

                TextField("Search problems...", text: $searchText)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.md)
            .frame(height: 44)
            .background(Color(hex: 0xF3F4F6))
            .cornerRadius(theme.radii.md)
            .padding(.horizontal, theme.spacing.md)
            .padding(.bottom, theme.spacing.sm)

            ScrollView {
                VStack(spacing: theme.spacing.sm) {
                    iPadCodingProblemRow(
                        title: "Two Sum",
                        difficulty: "Easy",
                        isSolved: true,
                        isSelected: selectedProblem == "Two Sum",
                        theme: theme
                    ) { selectedProblem = "Two Sum" }

                    iPadCodingProblemRow(
                        title: "Add Two Numbers",
                        difficulty: "Medium",
                        isSolved: false,
                        isSelected: selectedProblem == "Add Two Numbers",
                        theme: theme
                    ) { selectedProblem = "Add Two Numbers" }

                    iPadCodingProblemRow(
                        title: "Longest Substring",
                        difficulty: "Medium",
                        isSolved: false,
                        isSelected: selectedProblem == "Longest Substring",
                        theme: theme
                    ) { selectedProblem = "Longest Substring" }
                }
                .padding(.horizontal, theme.spacing.md)
            }
        }
        .frame(width: 220)
        .background(theme.colors.surface)
        .overlay(alignment: .trailing) {
            Rectangle().fill(theme.colors.border).frame(width: 1)
        }
    }

    // MARK: - Content Panel

    private var contentPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar with Run button
            HStack {
                Spacer()
                DSButton(
                    "Run",
                    config: DSButtonConfig(
                        style: .primary,
                        size: .small,
                        icon: Image(systemName: "play.fill")
                    )
                ) { }
            }
            .padding(theme.spacing.md)

            if selectedProblem != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        Text(selectedProblem ?? "")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        Text("Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.")
                            .font(theme.typography.body)
                            .foregroundColor(Color(hex: 0x374151))
                    }
                    .padding(theme.spacing.lg)
                }
            } else {
                Spacer()
                Text("Select a problem")
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .frame(maxWidth: .infinity)
                Spacer()
            }

            // Bottom description section
            Divider()
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("DESCRIPTION")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .textCase(.uppercase)

                Text(
                    selectedProblem == nil
                        ? "No problem selected."
                        : "Problem description shown above."
                )
                .font(theme.typography.body)
                .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(theme.spacing.md)
        }
        .background(theme.colors.background)
    }

    // MARK: - Output Panel

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("OUTPUT / TEST CASES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: 0x9CA3AF))
                .textCase(.uppercase)

            Text("Case 1")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            // Input block
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Input:")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: 0x6B7280))
                Text("nums = [2,7,11,15]\ntarget = 9")
                    .font(theme.typography.mono)
                    .foregroundColor(Color(hex: 0xD1D5DB))
                    .padding(theme.spacing.sm)
                    .background(Color(hex: 0x1F2937))
                    .cornerRadius(theme.radii.sm)
            }

            Text("Output: [0,1]")
                .font(theme.typography.mono)
                .foregroundColor(theme.colors.textPrimary)

            Divider()

            Text("Console")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: 0x9CA3AF))

            Text("No output yet...")
                .font(theme.typography.mono)
                .foregroundColor(Color(hex: 0x9CA3AF))
                .italic()

            Spacer()
        }
        .padding(theme.spacing.md)
        .frame(width: 140)
        .background(theme.colors.surface)
        .overlay(alignment: .leading) {
            Rectangle().fill(theme.colors.border).frame(width: 1)
        }
    }
}

// MARK: - Problem Row

private struct iPadCodingProblemRow: View {
    var title: String
    var difficulty: String
    var isSolved: Bool
    var isSelected: Bool = false
    var theme: DSTheme
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(difficulty)
                        .font(theme.typography.caption)
                        .foregroundColor(Color(hex: 0x6B7280))
                }

                Spacer()

                if isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.colors.success)
                        .font(.system(size: 16))
                } else {
                    Circle()
                        .stroke(Color(hex: 0xD1D5DB), lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(theme.spacing.sm)
            .background(
                isSelected
                    ? Color(hex: 0x6366F1).opacity(0.08)
                    : Color.clear
            )
            .cornerRadius(theme.radii.sm)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    iPadCodingView()
        .frame(width: 574, height: 800)
}
