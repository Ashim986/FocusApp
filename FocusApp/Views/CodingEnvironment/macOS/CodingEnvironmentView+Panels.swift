#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    var codeEditorPanel: some View {
        DSCard(config: .init(style: .surface, padding: 0, cornerRadius: 12)) {
            VStack(spacing: DSLayout.spacing(0)) {
                HStack(spacing: DSLayout.spacing(12)) {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                        Text(L10n.Coding.codeTitle)
                            .font(theme.typography.subtitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Text(L10n.Coding.solutionFilename(presenter.language.fileExtension))
                            .font(theme.typography.mono)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    languageSelect
                }
                .padding(.horizontal, DSLayout.spacing(12))
                .padding(.vertical, DSLayout.spacing(10))
                .background(theme.colors.surface)
                .overlay(
                    Rectangle()
                        .fill(theme.colors.border)
                        .frame(height: 1),
                    alignment: .bottom
                )

                if let notice = presenter.codeResetNotice {
                    HStack(spacing: DSLayout.spacing(8)) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.colors.warning)
                        Text(notice)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textPrimary)
                        Spacer()
                        DSButton(
                            "Dismiss",
                            config: .init(style: .ghost, size: .small, icon: Image(systemName: "xmark.circle.fill"))
                        ) {
                            presenter.codeResetNotice = nil
                        }
                    }
                    .padding(.horizontal, DSLayout.spacing(12))
                    .padding(.vertical, DSLayout.spacing(6))
                    .background(theme.colors.warning.opacity(0.12))
                    .overlay(
                        Rectangle()
                            .fill(theme.colors.border)
                            .frame(height: 1),
                        alignment: .bottom
                    )
                }

                CodeEditorView(
                    code: $presenter.code,
                    language: presenter.language,
                    diagnostics: presenter.errorDiagnostics,
                    executionLine: presenter.highlightedExecutionLine,
                    onRun: presenter.runCode
                )
            }
        }
    }

    private var languageSelect: some View {
        let items = ProgrammingLanguage.allCases.map { lang in
            DSSelectItem(id: lang.rawValue, title: lang.rawValue)
        }

        return DSSelect(
            placeholder: "Language",
            items: items,
            config: .init(style: .outlined, isCompact: true, minWidth: 140),
            state: .init(selectedId: presenter.language.rawValue),
            onSelect: { item in
                if let lang = ProgrammingLanguage(rawValue: item.id) {
                    presenter.changeLanguage(lang)
                }
            }
        )
    }

    var rightPanel: some View {
        VSplitView {
            codeEditorPanel
                .frame(minHeight: 320)

            bottomPanel
                .frame(
                    minHeight: codingCoordinator.isBottomPanelCollapsed ? 36 : 220,
                    idealHeight: codingCoordinator.isBottomPanelCollapsed ? 36 : 280
                )
        }
        .animation(.easeInOut(duration: 0.2), value: codingCoordinator.isBottomPanelCollapsed)
    }

    private var bottomPanel: some View {
        DSCard(config: .init(style: .surface, padding: 0, cornerRadius: 12)) {
            VStack(spacing: DSLayout.spacing(0)) {
                ModernTestCaseView(
                    presenter: presenter,
                    isCollapsed: $codingCoordinator.isBottomPanelCollapsed
                )

                if !codingCoordinator.isBottomPanelCollapsed {
                    ModernOutputView(
                        output: presenter.compilationOutput,
                        error: presenter.errorOutput,
                        testCases: presenter.testCases,
                        diagnostics: presenter.errorDiagnostics,
                        isRunning: presenter.isRunning,
                        hiddenTestsHaveFailures: presenter.hiddenTestsHaveFailures,
                        debugEntries: debugLogStore.entries,
                        logAnchor: presenter.executionLogAnchor
                    )
                }
            }
            .background(theme.colors.surface)
        }
    }
}

#endif
