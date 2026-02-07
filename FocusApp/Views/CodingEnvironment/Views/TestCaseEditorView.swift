import FocusDesignSystem
import SwiftUI

struct TestCaseEditorView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
            DSText(L10n.Coding.TestEditor.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                DSButton(action: presenter.addManualTestCase) {
                    HStack(spacing: 4) {
                        DSImage(systemName: "plus")
                        DSText(L10n.Coding.TestEditor.add)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.primary)
                }
                .buttonStyle(.plain)
            }

            if presenter.testCases.isEmpty {
            DSText(L10n.Coding.TestEditor.empty)
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(presenter.testCases.enumerated()), id: \.element.id) { index, testCase in
                    testCaseEditRow(index: index, testCase: testCase)
                }
            }
        }
    }

    private func testCaseEditRow(index: Int, testCase: TestCase) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                DSText(L10n.Coding.TestEditor.testFormat(index + 1))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                DSButton(action: {
                    presenter.removeTestCase(at: index)
                }, label: {
                    DSImage(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)
                })
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    DSText(L10n.Coding.TestEditor.inputLabel)
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)

                    DSTextField(
                        placeholder: "",
                        text: Binding(
                            get: { testCase.input },
                            set: { presenter.updateTestCaseInput(at: index, input: $0) }
                        ),
                        config: DSTextFieldConfig(style: .outlined, size: .small)
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                DSText(L10n.Coding.TestEditor.expectedLabel)
                        .font(.system(size: 10))
                        .foregroundColor(theme.colors.textSecondary)

                    DSTextField(
                        placeholder: "",
                        text: Binding(
                            get: { testCase.expectedOutput },
                            set: { presenter.updateTestCaseExpectedOutput(at: index, output: $0) }
                        ),
                        config: DSTextFieldConfig(style: .outlined, size: .small)
                    )
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated.opacity(0.4))
        )
    }
}
