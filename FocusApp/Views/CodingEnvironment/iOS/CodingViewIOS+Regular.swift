#if os(iOS)
// CodingViewIOS+Regular.swift
// FocusApp -- iPad regular (three-panel) layout for the adaptive coding view.

import FocusDesignSystem
import SwiftUI

// MARK: - Regular Layout (iPad three-panel)

extension CodingViewIOS {

    var regularThreePanelLayout: some View {
        HStack(spacing: 0) {
            // Left panel: Problem list
            regularProblemListPanel

            // Center panel: Code editor
            regularEditorPanel

            // Right panel: Output
            if !codingCoordinator.isBottomPanelCollapsed {
                regularOutputPanel
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if focusCoordinator.isSessionActive {
                FloatingMiniTimerIOS(coordinator: focusCoordinator)
                    .padding(24)
            }
        }
        .onAppear {
            presenter.ensureProblemSelection()
        }
        .onChange(of: presenter.isRunning) { _, running in
            if running, codingCoordinator.isBottomPanelCollapsed {
                codingCoordinator.toggleBottomPanel()
            }
        }
    }

    // MARK: Regular - Problem List Panel

    private var regularProblemListPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Problems")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(theme.spacing.md)

            // Search bar
            CodingSearchBar(searchText: $searchText)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.sm)

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(filteredSections) { section in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack {
                                Text(section.topic)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(theme.colors.textSecondary)
                                    .textCase(.uppercase)
                                Spacer()
                                Text("\(section.completedCount)/\(section.totalCount)")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .padding(.horizontal, theme.spacing.md)
                            .padding(.top, theme.spacing.sm)

                            ForEach(section.problems) { item in
                                CodingSidebarRow(
                                    item: item,
                                    isSelected: presenter.selectedProblem?.id == item.problem.id,
                                    theme: theme,
                                    onTap: {
                                        presenter.selectProblem(item)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.sm)
            }
        }
        .frame(width: 240)
        .background(theme.colors.surface)
        .overlay(alignment: .trailing) {
            Rectangle().fill(theme.colors.border).frame(width: 1)
        }
    }

    // MARK: Regular - Editor Panel

    private var regularEditorPanel: some View {
        VStack(spacing: 0) {
            // Toolbar
            regularEditorToolbar

            Divider()

            if let problem = presenter.selectedProblem {
                // Code editor area (CodeMirror)
                CodeMirrorEditorViewIOS(
                    code: $presenter.code,
                    language: presenter.language,
                    diagnostics: presenter.errorDiagnostics
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Problem name footer
                HStack {
                    Text(problem.name)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)

                    Spacer()

                    DSBadge(
                        problem.difficulty.rawValue,
                        config: DSBadgeConfig(
                            style: DifficultyBadgeHelper.badgeStyle(for: problem.difficulty)
                        )
                    )
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(theme.colors.surface)
            } else {
                // No problem selected
                VStack {
                    Spacer()
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 40))
                        .foregroundColor(theme.colors.textSecondary)
                    Text("Select a problem to start coding")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .padding(.top, theme.spacing.sm)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(theme.colors.background)
    }

    private var regularEditorToolbar: some View {
        HStack(spacing: theme.spacing.md) {
            // Language picker
            Picker("Language", selection: Binding(
                get: { presenter.language },
                set: { presenter.changeLanguage($0) }
            )) {
                ForEach(ProgrammingLanguage.allCases, id: \.self) { lang in
                    Text(lang.rawValue).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)

            Spacer()

            // Toggle output panel
            Button {
                codingCoordinator.toggleBottomPanel()
            } label: {
                Image(systemName: codingCoordinator.isBottomPanelCollapsed
                      ? "sidebar.right"
                      : "sidebar.right")
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .buttonStyle(.plain)

            // Run button
            DSButton(
                "Run",
                config: DSButtonConfig(
                    style: .secondary,
                    size: .small,
                    icon: Image(systemName: "play.fill")
                )
            ) {
                presenter.runCode()
            }

            // Submit button
            if presenter.selectedProblem != nil {
                DSButton(
                    "Submit",
                    config: DSButtonConfig(
                        style: .primary,
                        size: .small,
                        icon: Image(systemName: "paperplane.fill")
                    )
                ) {
                    presenter.runTests()
                }
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface)
    }

    // MARK: Regular - Output Panel

    private var regularOutputPanel: some View {
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
        .frame(width: 280)
        .background(theme.colors.surface)
        .overlay(alignment: .leading) {
            Rectangle().fill(theme.colors.border).frame(width: 1)
        }
    }
}

#endif
