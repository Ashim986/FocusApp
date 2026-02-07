// MacCodingView.swift
// FocusApp -- Mac Coding Environment (three-panel layout)

import FocusDesignSystem
import SwiftUI

struct MacCodingView: View {
    @Environment(\.dsTheme) var theme

    @State private var searchText = ""
    @State private var selectedProblem: String? = "Two Sum"
    @State private var selectedLanguage: CodingLanguage = .swift
    @State private var selectedOutputTab: OutputTab = .result

    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar
            macCodingToolbar

            Divider()

            // Three-panel layout
            HStack(spacing: 0) {
                // Left: Problem sidebar (280px)
                macProblemSidebar
                    .frame(width: 280)

                // Divider
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(width: 1)

                // Center: Code editor (flexible)
                macCodeEditor
                    .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(width: 1)

                // Right: Output panel (280px)
                macOutputPanel
                    .frame(width: 280)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Top Toolbar

    private var macCodingToolbar: some View {
        HStack(spacing: theme.spacing.md) {
            // Problem title
            if let problem = selectedProblem {
                Text(problem)
                    .font(theme.typography.subtitle)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Easy")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x059669))
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(Color(hex: 0xD1FAE5))
                    .cornerRadius(theme.radii.sm)
            }

            Spacer()

            // Language toggle
            macLanguageToggle

            // Run button
            Button { } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Run")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, theme.spacing.lg)
                .frame(height: 34)
                .background(Color(hex: 0x10B981))
                .cornerRadius(theme.radii.sm)
            }
            .buttonStyle(.plain)

            // Submit button
            Button { } label: {
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 12))
                    Text("Submit")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, theme.spacing.lg)
                .frame(height: 34)
                .background(Color(hex: 0x6366F1))
                .cornerRadius(theme.radii.sm)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, theme.spacing.lg)
        .frame(height: 48)
        .background(theme.colors.surface)
    }

    // MARK: - Language Toggle

    private var macLanguageToggle: some View {
        HStack(spacing: 0) {
            ForEach(CodingLanguage.allCases, id: \.self) { lang in
                Button {
                    selectedLanguage = lang
                } label: {
                    Text(lang.rawValue)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(
                            selectedLanguage == lang
                                ? theme.colors.textPrimary
                                : theme.colors.textSecondary
                        )
                        .padding(.horizontal, theme.spacing.md)
                        .frame(height: 28)
                        .background(
                            selectedLanguage == lang
                                ? theme.colors.surface
                                : Color.clear
                        )
                        .cornerRadius(theme.radii.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(theme.colors.surfaceElevated)
        .cornerRadius(theme.radii.sm)
    }

    // MARK: - Problem Sidebar

    private var macProblemSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)

                TextField("Search problems...", text: $searchText)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.md)
            .frame(height: 40)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.sm)
            .padding(theme.spacing.md)

            Divider()

            // Problem list
            ScrollView {
                VStack(spacing: theme.spacing.xs) {
                    macProblemRow(
                        number: 1,
                        title: "Two Sum",
                        difficulty: "Easy",
                        isSolved: true
                    )
                    macProblemRow(
                        number: 2,
                        title: "Add Two Numbers",
                        difficulty: "Medium",
                        isSolved: false
                    )
                    macProblemRow(
                        number: 3,
                        title: "Longest Substring Without Repeating",
                        difficulty: "Medium",
                        isSolved: false
                    )
                    macProblemRow(
                        number: 15,
                        title: "3Sum",
                        difficulty: "Medium",
                        isSolved: true
                    )
                    macProblemRow(
                        number: 20,
                        title: "Valid Parentheses",
                        difficulty: "Easy",
                        isSolved: true
                    )
                    macProblemRow(
                        number: 21,
                        title: "Merge Two Sorted Lists",
                        difficulty: "Easy",
                        isSolved: false
                    )
                    macProblemRow(
                        number: 49,
                        title: "Group Anagrams",
                        difficulty: "Medium",
                        isSolved: false
                    )
                    macProblemRow(
                        number: 76,
                        title: "Minimum Window Substring",
                        difficulty: "Hard",
                        isSolved: false
                    )
                }
                .padding(theme.spacing.md)
            }
        }
        .background(theme.colors.surface)
    }

    // MARK: - Problem Row

    private func macProblemRow(
        number: Int,
        title: String,
        difficulty: String,
        isSolved: Bool
    ) -> some View {
        Button {
            selectedProblem = title
        } label: {
            HStack(spacing: theme.spacing.sm) {
                // Solved indicator
                if isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: 0x10B981))
                        .font(.system(size: 14))
                } else {
                    Circle()
                        .stroke(theme.colors.border, lineWidth: 1)
                        .frame(width: 14, height: 14)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(number). \(title)")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Text(difficulty)
                        .font(theme.typography.caption)
                        .foregroundColor(macDifficultyColor(difficulty))
                }

                Spacer()
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.sm)
            .background(
                selectedProblem == title
                    ? Color(hex: 0x6366F1).opacity(0.08)
                    : Color.clear
            )
            .cornerRadius(theme.radii.sm)
        }
        .buttonStyle(.plain)
    }

    private func macDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return Color(hex: 0x059669)
        case "Medium": return Color(hex: 0xD97706)
        case "Hard": return Color(hex: 0xDC2626)
        default: return theme.colors.textSecondary
        }
    }

    // MARK: - Code Editor

    private var macCodeEditor: some View {
        VStack(spacing: 0) {
            // Editor with line numbers
            HStack(alignment: .top, spacing: 0) {
                // Line numbers
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(1...20, id: \.self) { line in
                        Text("\(line)")
                            .font(theme.typography.mono)
                            .foregroundColor(Color(hex: 0x6B7280))
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal, theme.spacing.sm)
                .padding(.top, theme.spacing.md)
                .background(Color(hex: 0x1F2937).opacity(0.5))

                Rectangle()
                    .fill(Color(hex: 0x374151))
                    .frame(width: 1)

                // Code area
                VStack(alignment: .leading, spacing: 0) {
                    macCodeLines
                }
                .padding(theme.spacing.md)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .background(Color(hex: 0x1F2937))
        }
    }

    private var macCodeLines: some View {
        VStack(alignment: .leading, spacing: 0) {
            macCodeLine("class", " Solution", " {", keywords: ["class"])
            macCodeLine("    func", " twoSum", "(_ nums: [Int], _ target: Int) -> [Int] {", keywords: ["func"])
            macCodeLine("        var", " map", " = [Int: Int]()", keywords: ["var"])
            macCodeLine("        for", " (i, num) ", "in", " nums.enumerated()", " {", keywords: ["for", "in"])
            macCodeLine("            let", " complement", " = target - num", keywords: ["let"])
            macCodeLine("            if let", " j", " = map[complement] {", keywords: ["if", "let"])
            macCodeLine("                return", " [j, i]", keywords: ["return"])
            macCodeLine("            }", keywords: [])
            macCodeLine("            map[num]", " = i", keywords: [])
            macCodeLine("        }", keywords: [])
            macCodeLine("        return", " []", keywords: ["return"])
            macCodeLine("    }", keywords: [])
            macCodeLine("}", keywords: [])
        }
    }

    private func macCodeLine(_ parts: String..., keywords: [String]) -> some View {
        let fullText = parts.joined()
        Text(fullText)
            .font(theme.typography.mono)
            .foregroundColor(Color(hex: 0xE5E7EB))
            .frame(height: 20, alignment: .leading)
    }

    // MARK: - Output Panel

    private var macOutputPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tab bar
            HStack(spacing: 0) {
                ForEach(OutputTab.allCases, id: \.self) { tab in
                    Button {
                        selectedOutputTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(theme.typography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                selectedOutputTab == tab
                                    ? Color(hex: 0x6366F1)
                                    : theme.colors.textSecondary
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .overlay(alignment: .bottom) {
                                if selectedOutputTab == tab {
                                    Rectangle()
                                        .fill(Color(hex: 0x6366F1))
                                        .frame(height: 2)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(theme.colors.surface)

            Divider()

            // Output content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    switch selectedOutputTab {
                    case .result:
                        macResultContent
                    case .console:
                        macConsoleContent
                    case .debug:
                        macDebugContent
                    }
                }
                .padding(theme.spacing.md)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(theme.colors.surface)
    }

    private var macResultContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Test Case 1")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Input:")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textSecondary)

                Text("nums = [2,7,11,15]\ntarget = 9")
                    .font(theme.typography.mono)
                    .foregroundColor(Color(hex: 0xE5E7EB))
                    .padding(theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0x1F2937))
                    .cornerRadius(theme.radii.sm)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Expected:")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textSecondary)

                Text("[0, 1]")
                    .font(theme.typography.mono)
                    .foregroundColor(Color(hex: 0x10B981))
                    .padding(theme.spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0x1F2937))
                    .cornerRadius(theme.radii.sm)
            }

            // Status badge
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: 0x10B981))
                Text("Accepted")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x10B981))
            }
        }
    }

    private var macConsoleContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("No output yet...")
                .font(theme.typography.mono)
                .foregroundColor(theme.colors.textSecondary)
                .italic()
        }
    }

    private var macDebugContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("No debug information available.")
                .font(theme.typography.mono)
                .foregroundColor(theme.colors.textSecondary)
                .italic()
        }
    }
}

// MARK: - Coding Language

private enum CodingLanguage: String, CaseIterable {
    case swift = "Swift"
    case python = "Python"
}

// MARK: - Output Tab

private enum OutputTab: String, CaseIterable {
    case result = "Result"
    case console = "Console"
    case debug = "Debug"
}

#Preview("Mac Coding") {
    MacCodingView()
        .frame(width: 1200, height: 760)
}
