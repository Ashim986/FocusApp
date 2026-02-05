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
            Text(L10n.Coding.Solution.testCaseLabel(index + 1))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.appGray400)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Coding.Solution.inputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appAmber)
                    Text(testCase.input)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.appGray200)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Coding.Solution.outputLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appGreen)
                    Text(testCase.expectedOutput)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.appGray200)
                }
            }

            if let explanation = testCase.explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
                    .padding(.top, 4)
            }
        }
        .padding(10)
        .background(Color.appGray800.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
