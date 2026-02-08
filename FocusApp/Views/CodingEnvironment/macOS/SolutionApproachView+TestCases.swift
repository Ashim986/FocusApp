#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension SolutionApproachView {
    func testCasesContent(_ testCases: [SolutionTestCase]) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                testCaseRow(testCase, index: index)
            }
        }
    }

    func testCaseRow(_ testCase: SolutionTestCase, index: Int) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            Text(L10n.Coding.Solution.testCaseLabel(index + 1))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(theme.colors.textSecondary)

            HStack(spacing: DSLayout.spacing(12)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                    Text(L10n.Coding.Solution.inputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.warning)
                    Text(testCase.input)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(theme.colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                    Text(L10n.Coding.Solution.outputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(theme.colors.success)
                    Text(testCase.expectedOutput)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(theme.colors.textPrimary)
                }
            }

            if let explanation = testCase.explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.top, DSLayout.spacing(4))
            }
        }
        .padding(DSLayout.spacing(10))
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#endif
