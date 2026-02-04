import SwiftUI

extension CodingEnvironmentView {
    var codeEditorPanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Code")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                languageMenu

                Text("Solution.\(presenter.language.fileExtension)")
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

            CodeEditorView(code: $presenter.code, language: presenter.language)
        }
    }

    private var languageMenu: some View {
        Menu {
            ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { lang in
                Button(action: { presenter.changeLanguage(lang) }) {
                    Text(lang.rawValue)
                }
            }
        } label: {
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
        }
        .menuStyle(.borderlessButton)
    }

    var rightPanel: some View {
        VSplitView {
            codeEditorPanel
                .frame(minHeight: 320)

            bottomPanel
                .frame(minHeight: isBottomPanelCollapsed ? 36 : 220, idealHeight: isBottomPanelCollapsed ? 36 : 280)
        }
        .animation(.easeInOut(duration: 0.2), value: isBottomPanelCollapsed)
    }

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Console")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: { isBottomPanelCollapsed.toggle() }) {
                    HStack(spacing: 4) {
                        Text(isBottomPanelCollapsed ? "Expand" : "Collapse")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appGray400)
                        Image(systemName: isBottomPanelCollapsed ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appGray400)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray800)
            .overlay(
                Rectangle()
                    .fill(Color.appGray700)
                    .frame(height: 1),
                alignment: .bottom
            )

            if !isBottomPanelCollapsed {
                VStack(spacing: 0) {
                    ModernTestCaseView(presenter: presenter)

                    ModernOutputView(
                        output: presenter.compilationOutput,
                        error: presenter.errorOutput,
                        testCases: presenter.testCases,
                        isRunning: presenter.isRunning
                    )
                }
            }
        }
        .background(Color.appGray900)
    }
}
