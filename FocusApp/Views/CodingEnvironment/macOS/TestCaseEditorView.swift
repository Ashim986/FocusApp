#if os(macOS)
import FocusDesignSystem
import SwiftUI

struct TestCaseEditorView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
            HStack {
            Text(L10n.Coding.TestEditor.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                DSButton(
                    L10n.Coding.TestEditor.add,
                    config: .init(style: .secondary, size: .small, icon: Image(systemName: "plus"))
                ) {
                    presenter.addManualTestCase()
                }
            }

            if presenter.testCases.isEmpty {
            Text(L10n.Coding.TestEditor.empty)
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.vertical, DSLayout.spacing(8))
            } else {
                ForEach(Array(presenter.testCases.enumerated()), id: \.element.id) { index, testCase in
                    testCaseEditRow(index: index, testCase: testCase)
                }
            }
        }
    }

    private func testCaseEditRow(index: Int, testCase: TestCase) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            HStack {
                Text(L10n.Coding.TestEditor.testFormat(index + 1))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                DSButton(
                    "Delete",
                    config: .init(style: .destructive, size: .small, icon: Image(systemName: "trash"))
                ) {
                    presenter.removeTestCase(at: index)
                }
            }

            HStack(spacing: DSLayout.spacing(8)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                    Text(L10n.Coding.TestEditor.inputLabel)
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

                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                Text(L10n.Coding.TestEditor.expectedLabel)
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
        .padding(DSLayout.spacing(8))
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated.opacity(0.4))
        )
    }
}

#endif
