import SwiftUI

extension CodingEnvironmentView {
    var codeEditorPanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(L10n.Coding.codeTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                languageMenu

                Text(L10n.Coding.solutionFilename(presenter.language.fileExtension))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.appGray400)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray900)
            .overlay(
                Rectangle()
                    .fill(Color.appGray700)
                    .frame(height: 1),
                alignment: .bottom
            )

            if let notice = presenter.codeResetNotice {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color.appAmber)
                    Text(notice)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appGray200)
                    Spacer()
                    Button(action: { presenter.codeResetNotice = nil }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray500)
                    })
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.appAmber.opacity(0.12))
                .overlay(
                    Rectangle()
                        .fill(Color.appGray700)
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

    private var languageMenu: some View {
        Menu(content: {
            ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { lang in
                Button(action: {
                    presenter.changeLanguage(lang)
                }, label: {
                    Text(lang.rawValue)
                })
            }
        }, label: {
            HStack(spacing: 4) {
                Image(systemName: presenter.language == .swift ? "swift" : "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(presenter.language == .swift ? Color.orange : Color.blue)

                Text(presenter.language.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)

                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color.appGray500)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.appGray800)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        })
        .menuStyle(.borderlessButton)
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
        VStack(spacing: 0) {
            VStack(spacing: 0) {
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
        }
        .background(Color.appGray900)
    }
}
