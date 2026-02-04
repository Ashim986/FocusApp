import SwiftUI

extension CodingEnvironmentView {
    var codeEditorPanel: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: presenter.language == .swift ? "swift" : "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(presenter.language == .swift ? Color.orange : Color.blue)

                    Text("Solution.\(presenter.language.fileExtension)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.appGray800)

                Rectangle()
                    .fill(Color.appGray800)
                    .frame(height: 32)

                Spacer()
            }
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
