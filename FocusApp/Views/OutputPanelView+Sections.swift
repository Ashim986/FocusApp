import FocusDesignSystem
import SwiftUI

extension OutputPanelView {
    @ViewBuilder
    var testResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            DSText(L10n.Output.testResults)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.colors.textSecondary)

            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                testCaseRow(index: index, testCase: testCase)
            }
        }
    }

    func testCaseRow(index: Int, testCase: TestCase) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let passed = testCase.passed {
                    DSImage(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(passed ? theme.colors.success : theme.colors.danger)
                } else {
                    DSImage(systemName: "circle.dashed")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                }

                DSText(L10n.Output.testCaseLabel( index + 1))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)

                if let passed = testCase.passed {
                    DSText(passed ? L10n.Output.passed : L10n.Output.failed)
                        .font(.system(size: 11))
                        .foregroundColor(passed ? theme.colors.success : theme.colors.danger)
                }
            }

            if testCase.passed == false, let actual = testCase.actualOutput {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        DSText(L10n.Output.expected)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                        DSText(testCase.expectedOutput)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textPrimary.opacity(0.8))
                    }
                    HStack(spacing: 4) {
                        DSText(L10n.Output.actual)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                        DSText(actual)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.danger)
                    }
                }
                .padding(.leading, 22)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated.opacity(0.5))
        )
    }

    @ViewBuilder
    var consoleOutputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                DSImage(systemName: "terminal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.success)

                DSText(L10n.Output.consoleOutput)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                let lineCount = output.components(separatedBy: "\n").filter { !$0.isEmpty }.count
                DSText(L10n.Output.lineCount(lineCount))
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(theme.colors.surfaceElevated)
                    .cornerRadius(4)
            }

            ConsoleOutputView(output: output)
        }
    }

    @ViewBuilder
    var errorSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                DSImage(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.danger)

                DSText(L10n.Output.errorOutput)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.colors.danger)
            }

            DSText(error)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(theme.colors.danger)
                .textSelection(.enabled)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.colors.danger.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(theme.colors.danger.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }

    @ViewBuilder
    var emptyState: some View {
        VStack(spacing: 8) {
            DSImage(systemName: "terminal")
                .font(.system(size: 24))
                .foregroundColor(theme.colors.textSecondary)

            DSText(L10n.Output.emptyState)
                .font(.system(size: 12))
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
