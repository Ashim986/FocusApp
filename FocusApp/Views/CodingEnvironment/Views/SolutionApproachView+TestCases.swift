import FocusDesignSystem
import SwiftUI

extension SolutionApproachView {
    func testCasesContent(_ testCases: [SolutionTestCase]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                testCaseRow(testCase, index: index)
            }
        }
    }

    func testCaseRow(_ testCase: SolutionTestCase, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            DSText(L10n.Coding.Solution.testCaseLabel(index + 1))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.colors.textSecondary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    DSText(L10n.Coding.Solution.inputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.warning)
                    DSText(testCase.input)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(theme.colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    DSText(L10n.Coding.Solution.outputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.success)
                    DSText(testCase.expectedOutput)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(theme.colors.textPrimary)
                }
            }

            if let explanation = testCase.explanation, !explanation.isEmpty {
                DSText(explanation)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.top, 4)
            }
        }
        .padding(10)
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
