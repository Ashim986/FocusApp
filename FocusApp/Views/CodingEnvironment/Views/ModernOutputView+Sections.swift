import SwiftUI

extension ModernOutputView {
    @ViewBuilder
    var resultContent: some View {
        if !hasTestResults && output.isEmpty && error.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "play.circle")
                    .font(.system(size: 28))
                    .foregroundColor(Color.appGray600)
            Text(L10n.Coding.Output.empty)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if hasTestResults {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    let statusColor = hasFailures ? Color.appRed : (allTestsPassed ? Color.appGreen : Color.appAmber)
                    HStack(spacing: 10) {
                        Image(systemName: hasFailures ? "xmark.circle.fill" : (allTestsPassed ? "checkmark.circle.fill" : "clock.fill"))
                            .font(.system(size: 24))
                            .foregroundColor(statusColor)

                        VStack(alignment: .leading, spacing: 2) {
                        Text(hasFailures
                            ? L10n.Coding.Output.wrongAnswer
                            : (allTestsPassed ? L10n.Coding.Output.accepted : L10n.Coding.Output.running))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(statusColor)

                            let passedCount = testCases.filter { $0.passed == true }.count
                        Text(L10n.Coding.Output.testsPassed(passedCount, testCases.count))
                                .font(.system(size: 11))
                                .foregroundColor(Color.appGray500)
                        }

                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(statusColor.opacity(0.1))
                    )

                    ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                        if let passed = testCase.passed {
                            testResultRow(index: index, testCase: testCase, passed: passed)
                        }
                    }
                }
                .padding(12)
            }
        } else if !error.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.appRed)
                    Text(L10n.Coding.Output.compilationError)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.appRed)
                    }

                    Text(error)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.appRed)
                        .textSelection(.enabled)
                }
                .padding(12)
            }
        } else {
            outputContent
        }
    }

    func testResultRow(index: Int, testCase: TestCase, passed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(passed ? Color.appGreen : Color.appRed)

            Text(L10n.Coding.Output.testFormat( index + 1))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Text(passed
                    ? L10n.Coding.Output.passed
                    : L10n.Coding.Output.failed)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(passed ? Color.appGreen : Color.appRed)
            }

            if !passed {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 4) {
                            Text(L10n.Coding.Output.inputLabel)
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
                            .frame(width: 60, alignment: .leading)
                        Text(testCase.input)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGray300)
                    }

                    HStack(alignment: .top, spacing: 4) {
                            Text(L10n.Coding.Output.expectedLabel)
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
                            .frame(width: 60, alignment: .leading)
                        Text(testCase.expectedOutput)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGreen)
                    }

                    if let actual = testCase.actualOutput {
                        HStack(alignment: .top, spacing: 4) {
                            Text(L10n.Coding.Output.outputLabel)
                                .font(.system(size: 10))
                                .foregroundColor(Color.appGray500)
                                .frame(width: 60, alignment: .leading)
                            Text(actual)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(Color.appRed)
                        }
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appGray800.opacity(0.5))
        )
    }

    @ViewBuilder
    var outputContent: some View {
        if output.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "terminal")
                    .font(.system(size: 28))
                    .foregroundColor(Color.appGray600)
            Text(L10n.Coding.Output.noOutput)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if !output.isEmpty {
                        ConsoleOutputView(output: output)
                    }
                }
                .padding(12)
            }
        }
    }

    @ViewBuilder
    var debugContent: some View {
        if error.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "ladybug")
                    .font(.system(size: 26))
                    .foregroundColor(Color.appGray600)
            Text(L10n.Coding.Output.noDebug)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Coding.Output.stderrLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.appRed)

                    Text(error)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.appRed)
                        .textSelection(.enabled)
                        .padding(8)
                        .background(Color.appRed.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(12)
            }
        }
    }
}
