#if os(iOS)
// CodingViewIOS.swift
// FocusApp -- Unified adaptive coding view for iPhone (compact) and iPad (regular)
// Uses @Environment(\.horizontalSizeClass) to branch between layouts.

import FocusDesignSystem
import SwiftUI

// MARK: - Coding Detail Tab (compact layout)

private enum CodingDetailTab: String, CaseIterable {
    case desc = "Desc"
    case solution = "Solution"
    case code = "Code"
}

// MARK: - CodingViewiOS

struct CodingViewIOS: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @ObservedObject var codingCoordinator: CodingCoordinator
    @ObservedObject var focusCoordinator: FocusCoordinator
    @ObservedObject var codingFlowCoordinator: CodingFlowCoordinator

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    @State var searchText = ""
    @State private var selectedDetailTab: CodingDetailTab = .desc

    var body: some View {
        if sizeClass == .regular {
            regularThreePanelLayout
        } else {
            compactListOrDetail
        }
    }

    // MARK: - Filtered Sections (shared)

    var filteredSections: [CodingProblemSection] {
        let sections = presenter.problemSections
        guard !searchText.isEmpty else { return sections }
        return sections.compactMap { section in
            let filtered = section.problems.filter {
                $0.problem.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !filtered.isEmpty else { return nil }
            return CodingProblemSection(
                id: section.id,
                dayId: section.dayId,
                topic: section.topic,
                isToday: section.isToday,
                problems: filtered,
                completedCount: section.completedCount,
                totalCount: section.totalCount
            )
        }
    }
}

// MARK: - Compact Layout (iPhone)

extension CodingViewIOS {

    @ViewBuilder
    private var compactListOrDetail: some View {
        if codingFlowCoordinator.isDetailShown {
            compactDetailView
        } else {
            compactListView
        }
    }

    // MARK: Compact List

    private var compactListView: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Spacer()

                Text("Problems")
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal, theme.spacing.lg)
            .background(theme.colors.background)

            ScrollView {
                VStack(spacing: theme.spacing.md) {
                    // Search bar
                    CodingSearchBar(searchText: $searchText)
                        .padding(.horizontal, theme.spacing.lg)

                    // Problem sections by day
                    ForEach(filteredSections) { section in
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            // Section header
                            HStack {
                                Text("Day \(section.dayId): \(section.topic)")
                                    .font(theme.typography.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(theme.colors.textPrimary)

                                Spacer()

                                Text("\(section.completedCount)/\(section.totalCount)")
                                    .font(theme.typography.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: 0x6B7280))

                                if section.isToday {
                                    Text("Today")
                                        .font(theme.typography.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(hex: 0x6366F1))
                                        .padding(.horizontal, theme.spacing.sm)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: 0x6366F1).opacity(0.1))
                                        .cornerRadius(theme.radii.sm)
                                }
                            }
                            .padding(.horizontal, theme.spacing.lg)

                            // Problem cards
                            ForEach(section.problems) { item in
                                compactProblemCard(item: item, dayId: section.dayId)
                                    .padding(.horizontal, theme.spacing.lg)
                            }
                        }
                    }
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    private func compactProblemCard(item: CodingProblemItem, dayId: Int) -> some View {
        Button {
            codingFlowCoordinator.openProblem(
                problem: item.problem,
                day: dayId,
                index: item.index
            )
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(item.problem.displayName)
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Text(item.problem.difficulty.rawValue)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(difficultyTextColor(item.problem.difficulty))
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                        .background(difficultyBgColor(item.problem.difficulty))
                        .cornerRadius(theme.radii.sm)
                }

                Spacer()

                // Completion indicator
                if item.isCompleted {
                    ZStack {
                        Circle()
                            .fill(Color(hex: 0x059669))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(Color(hex: 0xD1D5DB), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(theme.spacing.lg)
            .background(theme.colors.surface)
            .cornerRadius(theme.radii.md)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.md)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: Compact Detail

    private var compactDetailView: some View {
        let problem = presenter.selectedProblem

        return VStack(spacing: 0) {
            // Header bar
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

            // Back row
            HStack(spacing: theme.spacing.sm) {
                Button {
                    codingFlowCoordinator.popToList()
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
                        selectedDetailTab = tab
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(theme.typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    selectedDetailTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color(hex: 0x6B7280)
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)

                            Rectangle()
                                .fill(
                                    selectedDetailTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color.clear
                                )
                                .frame(height: 2)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
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
                switch selectedDetailTab {
                case .desc:
                    compactDescriptionContent
                case .solution:
                    compactSolutionContent
                case .code:
                    compactCodeContent
                }
            }

            // Bottom action bar
            compactBottomActionBar

            // Floating mini timer
            if focusCoordinator.isSessionActive {
                FloatingMiniTimerIOS(coordinator: focusCoordinator)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: Compact - Description Tab

    private var compactDescriptionContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let problem = presenter.selectedProblem {
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

            if presenter.isLoadingProblem && presenter.problemDescriptionText.isEmpty {
                HStack {
                    ProgressView()
                        .controlSize(.small)
                    Text("Loading problem...")
                        .font(theme.typography.body)
                        .foregroundColor(Color(hex: 0x6B7280))
                }
            } else if !presenter.problemDescriptionText.isEmpty {
                Text(presenter.problemDescriptionText)
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
            if let problem = presenter.selectedProblem {
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

    // MARK: Compact - Solution Tab

    private var compactSolutionContent: some View {
        ScrollView {
            SolutionViewIOS(solution: presenter.currentSolution)
                .padding(theme.spacing.lg)
        }
    }

    // MARK: Compact - Code Tab

    private var compactCodeContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Code editor (CodeMirror for iOS)
            CodeMirrorEditorViewIOS(
                code: $presenter.code,
                language: presenter.language,
                diagnostics: presenter.errorDiagnostics
            )
            .cornerRadius(theme.radii.md)
            .frame(minHeight: 300)
            .padding(theme.spacing.lg)

            // Tabbed output panel
            if !presenter.compilationOutput.isEmpty || !presenter.errorOutput.isEmpty
                || presenter.isRunning || presenter.testCases.contains(where: { $0.passed != nil }) {
                OutputViewIOS(
                    output: presenter.compilationOutput,
                    error: presenter.errorOutput,
                    testResults: presenter.testCases,
                    isRunning: presenter.isRunning,
                    hiddenTestProgress: presenter.compilationOutput,
                    hiddenTestsHaveFailures: presenter.hiddenTestsHaveFailures,
                    diagnostics: presenter.errorDiagnostics,
                    hasTestResults: presenter.testCases.contains(where: { $0.passed != nil })
                )
                .frame(height: 220)
                .cornerRadius(theme.radii.md)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.lg)
            }
        }
    }

    // MARK: Compact - Bottom Action Bar

    private var compactBottomActionBar: some View {
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
            .disabled(presenter.isRunning || presenter.isLoadingProblem)

            // Submit button
            Button {
                presenter.runTests()
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
            .disabled(presenter.isRunning || presenter.isLoadingProblem)
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
}

// MARK: - Shared Helpers

extension CodingViewIOS {

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

// MARK: - Shared Sub-Views (private to file)

// MARK: CodingSearchBar

struct CodingSearchBar: View {
    @Binding var searchText: String

    var body: some View {
        DSTextField(
            placeholder: "Search problems...",
            text: $searchText
        )
    }
}

// MARK: CodingSidebarRow

struct CodingSidebarRow: View {
    let item: CodingProblemItem
    let isSelected: Bool
    let theme: DSTheme
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.problem.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Text(item.problem.difficulty.rawValue)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                if item.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.colors.success)
                        .font(.system(size: 14))
                } else {
                    Circle()
                        .stroke(theme.colors.border, lineWidth: 1)
                        .frame(width: 14, height: 14)
                }
            }
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xs)
            .background(
                isSelected
                    ? theme.colors.primary.opacity(0.08)
                    : Color.clear
            )
            .cornerRadius(theme.radii.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: CodingTestCaseRow

private struct CodingTestCaseRow: View {
    let index: Int
    let testCase: TestCase
    let theme: DSTheme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Case \(index + 1)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            if !testCase.input.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Input:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                    Text(testCase.input)
                        .font(theme.typography.mono)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(theme.spacing.xs)
                        .background(Color(hex: 0x1F2937))
                        .cornerRadius(theme.radii.sm)
                }
            }

            if !testCase.expectedOutput.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Expected:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                    Text(testCase.expectedOutput)
                        .font(theme.typography.mono)
                        .foregroundColor(theme.colors.textPrimary)
                }
            }
        }
        .padding(theme.spacing.sm)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.sm)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.sm)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }
}
#endif
