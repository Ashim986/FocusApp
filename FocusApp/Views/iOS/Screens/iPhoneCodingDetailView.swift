#if os(iOS)
// iPhoneCodingDetailView.swift
// FocusApp -- iPhone Coding Problem Detail screen (393x852)

import FocusDesignSystem
import SwiftUI

// MARK: - Coding Detail Tab

private enum CodingDetailTab: String, CaseIterable {
    case desc = "Desc"
    case solution = "Solution"
    case code = "Code"
}

struct iPhoneCodingDetailView: View {
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    @ObservedObject var presenter: CodingEnvironmentPresenter
    @ObservedObject var codingCoordinator: CodingCoordinator
    @ObservedObject var focusCoordinator: FocusCoordinator
    var onBack: () -> Void

    @State private var selectedTab: CodingDetailTab = .desc

    private var problem: Problem? { presenter.selectedProblem }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            // Back row
            HStack(spacing: theme.spacing.sm) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                }
                .buttonStyle(.plain)

                Text(problem?.displayName ?? "Problem")
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)
                    .lineLimit(1)

                Spacer()

                // Language toggle
                Button {
                    let newLang: ProgrammingLanguage = presenter.language == .swift ? .python : .swift
                    presenter.changeLanguage(newLang)
                } label: {
                    Text(presenter.language == .swift ? "Swift" : "Python")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x6366F1))
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(Color(hex: 0x6366F1).opacity(0.1))
                        .cornerRadius(theme.radii.sm)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 44)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(CodingDetailTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(theme.typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    selectedTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color(hex: 0x6B7280)
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)

                            Rectangle()
                                .fill(
                                    selectedTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color.clear
                                )
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(height: 1)
            }

            // Content
            ScrollView {
                switch selectedTab {
                case .desc:
                    descriptionContent
                case .solution:
                    solutionContent
                case .code:
                    codeContent
                }
            }

            // Bottom action bar
            bottomActionBar
        }
        .background(theme.colors.background)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Description Content

    private var descriptionContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let problem {
                Text(problem.displayName)
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)

                // Difficulty badge
                Text(problem.difficulty.rawValue)
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(difficultyTextColor(problem.difficulty))
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(difficultyBgColor(problem.difficulty))
                    .cornerRadius(theme.radii.sm)
            }

            if presenter.isLoadingProblem {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Loading problem...")
                        .font(theme.typography.body)
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            } else if let content = presenter.problemContent {
                // Render HTML content as plain text (strip tags)
                Text(stripHTML(content.content))
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x374151))
                    .lineSpacing(4)
            } else {
                Text("Select a problem to view its description.")
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .italic()
            }

            // Open on LeetCode button
            if let problem {
                Button {
                    if let url = URL(string: problem.url) {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14))
                        Text("Open on LeetCode")
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color(hex: 0x6366F1))
                }
                .buttonStyle(.plain)
                .padding(.top, theme.spacing.sm)
            }
        }
        .padding(theme.spacing.lg)
    }

    // MARK: - Solution Content

    private var solutionContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let solution = presenter.currentSolution {
                Text(solution.summary)
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x374151))
                    .lineSpacing(4)

                ForEach(solution.approaches) { approach in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text(approach.name)
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Text("Time: \(approach.complexity.time)")
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))

                        Text("Space: \(approach.complexity.space)")
                            .font(theme.typography.caption)
                            .foregroundColor(Color(hex: 0x6B7280))

                        Text(approach.explanation)
                            .font(theme.typography.body)
                            .foregroundColor(Color(hex: 0x374151))
                            .lineSpacing(4)
                    }
                    .padding(theme.spacing.md)
                    .background(theme.colors.surface)
                    .cornerRadius(theme.radii.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radii.md)
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
                }
            } else {
                Text("No solution available for this problem.")
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x9CA3AF))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(theme.spacing.lg)
    }

    // MARK: - Code Content

    private var codeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Code editor (simple TextEditor for iOS)
            TextEditor(text: $presenter.code)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(theme.spacing.md)
                .background(Color(hex: 0x1F2937))
                .foregroundColor(Color(hex: 0xD1D5DB))
                .cornerRadius(theme.radii.md)
                .frame(minHeight: 300)
                .padding(theme.spacing.lg)

            // Output section
            if !presenter.compilationOutput.isEmpty || !presenter.errorOutput.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("Output")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: 0x9CA3AF))

                    if !presenter.compilationOutput.isEmpty {
                        Text(presenter.compilationOutput)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(Color(hex: 0xD1D5DB))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !presenter.errorOutput.isEmpty {
                        Text(presenter.errorOutput)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(theme.colors.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(theme.spacing.md)
                .background(Color(hex: 0x111827))
                .cornerRadius(theme.radii.md)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.lg)
            }
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        HStack(spacing: theme.spacing.md) {
            // Run button
            Button {
                presenter.runCode()
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    if presenter.isRunning {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                    }
                    Text(presenter.isRunning ? "Running..." : "Run")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: 0x059669))
                .cornerRadius(theme.radii.md)
            }
            .buttonStyle(.plain)
            .disabled(presenter.isRunning)

            // Submit button
            Button {
                Task {
                    _ = await presenter.submitToLeetCodeDirect()
                }
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                    Text("Submit")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color(hex: 0x6366F1))
                .cornerRadius(theme.radii.md)
            }
            .buttonStyle(.plain)
            .disabled(presenter.isRunning)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.vertical, theme.spacing.md)
        .background(theme.colors.surface)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 1)
        }
    }

    // MARK: - Helpers

    private func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        if let attributed = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ],
            documentAttributes: nil
        ) {
            return attributed.string
        }
        // Fallback: strip tags with regex
        return html.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
    }

    private func difficultyTextColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Color(hex: 0x059669)
        case .medium: return Color(hex: 0xD97706)
        case .hard: return Color(hex: 0xDC2626)
        }
    }

    private func difficultyBgColor(_ difficulty: Difficulty) -> Color {
        switch difficulty {
        case .easy: return Color(hex: 0xD1FAE5)
        case .medium: return Color(hex: 0xFEF3C7)
        case .hard: return Color(hex: 0xFEE2E2)
        }
    }
}
#endif
