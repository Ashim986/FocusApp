import SwiftUI

extension OutputPanelView {
    @ViewBuilder
    var testResultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test Results")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.appGray400)

            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                testCaseRow(index: index, testCase: testCase)
            }
        }
    }

    func testCaseRow(index: Int, testCase: TestCase) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if let passed = testCase.passed {
                    Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(passed ? Color.appGreen : Color.appRed)
                } else {
                    Image(systemName: "circle.dashed")
                        .font(.system(size: 14))
                        .foregroundColor(Color.appGray500)
                }

                Text("Test \(index + 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                if let passed = testCase.passed {
                    Text(passed ? "Passed" : "Failed")
                        .font(.system(size: 11))
                        .foregroundColor(passed ? Color.appGreen : Color.appRed)
                }
            }

            if testCase.passed == false, let actual = testCase.actualOutput {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Expected:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appGray500)
                        Text(testCase.expectedOutput)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGray300)
                    }
                    HStack(spacing: 4) {
                        Text("Actual:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appGray500)
                        Text(actual)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appRed)
                    }
                }
                .padding(.leading, 22)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appGray800.opacity(0.5))
        )
    }

    @ViewBuilder
    var consoleOutputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGreen)

                Text("Console Output")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.appGray400)

                Spacer()

                let lineCount = output.components(separatedBy: "\n").filter { !$0.isEmpty }.count
                Text("\(lineCount) line\(lineCount == 1 ? "" : "s")")
                    .font(.system(size: 9))
                    .foregroundColor(Color.appGray500)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appGray800)
                    .cornerRadius(4)
            }

            ConsoleOutputView(output: output)
        }
    }

    @ViewBuilder
    var errorSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(Color.appRed)

                Text("Error Output")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.appRed)
            }

            Text(error)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.appRed)
                .textSelection(.enabled)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appRed.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.appRed.opacity(0.3), lineWidth: 1)
                        )
                )
        }
    }

    @ViewBuilder
    var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "terminal")
                .font(.system(size: 24))
                .foregroundColor(Color.appGray600)

            Text("Run your code to see output")
                .font(.system(size: 12))
                .foregroundColor(Color.appGray500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
