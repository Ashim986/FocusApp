import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

extension ModernOutputView {
    private var executionEntries: [DebugLogEntry] {
        let filtered = debugEntries.filter { entry in
            guard entry.category == .execution else { return false }
            if let anchor = logAnchor {
                return entry.timestamp >= anchor
            }
            return true
        }
        return filtered.sorted { $0.timestamp < $1.timestamp }
    }

    @ViewBuilder
    var resultContent: some View {
        if isRunning, !hasTestResults {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    if !output.isEmpty {
                        coloredProgressText(output)
                    } else {
                        Text(L10n.Coding.Output.running)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.appGray400)
                    }

                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 14, height: 14)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !hasTestResults && output.isEmpty && error.isEmpty {
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

                Text(L10n.Coding.Output.testFormat(index + 1))
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
        if error.isEmpty && executionEntries.isEmpty && diagnostics.isEmpty {
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
                    if !diagnostics.isEmpty {
                        Text("Diagnostics")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appRed)

                        VStack(spacing: 6) {
                            ForEach(diagnostics, id: \.self) { diagnostic in
                                diagnosticRow(diagnostic)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    if !error.isEmpty {
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

                    if !executionEntries.isEmpty {
                        Text(L10n.Debug.logsTitle)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.appGray400)
                            .padding(.top, (error.isEmpty && diagnostics.isEmpty) ? 0 : 6)

                        VStack(spacing: 8) {
                            ForEach(executionEntries) { entry in
                                DebugLogRow(entry: entry)
                            }
                        }
                    }
                }
                .padding(12)
            }
        }
    }

    @ViewBuilder
    private func diagnosticRow(_ diagnostic: CodeEditorDiagnostic) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(diagnosticLocation(diagnostic))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.appRed)
                Text(diagnostic.message)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray200)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)

            Button(
                action: { copyDiagnostic(diagnostic) },
                label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 9))
                        .foregroundColor(Color.appGray500)
                }
            )
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(Color.appRed.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func diagnosticLocation(_ diagnostic: CodeEditorDiagnostic) -> String {
        if let column = diagnostic.column {
            return "Line \(diagnostic.line), Col \(column)"
        }
        return "Line \(diagnostic.line)"
    }

    private func copyDiagnostic(_ diagnostic: CodeEditorDiagnostic) {
        #if canImport(AppKit)
        let text = "\(diagnosticLocation(diagnostic)): \(diagnostic.message)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }

    // MARK: - Colored Progress Text

    /// Renders hidden test progress with green ✓ and red ✗ symbols.
    /// Expected format: "Hidden test 3/50  ✓ 2  ✗ 1"
    private func coloredProgressText(_ text: String) -> Text {
        let baseColor: Color = hiddenTestsHaveFailures
            ? Color.appRed.opacity(0.85)
            : Color.appGreen.opacity(0.85)
        let font = Font.system(size: 13, weight: .semibold)

        guard let checkIndex = text.firstIndex(of: "✓") else {
            return Text(text).font(font).foregroundColor(baseColor)
        }

        let prefix = String(text[text.startIndex..<checkIndex])
        let remainder = String(text[checkIndex...])

        guard let crossIndex = remainder.firstIndex(of: "✗") else {
            return Text(prefix).font(font).foregroundColor(baseColor)
                + Text(remainder).font(font).foregroundColor(Color.appGreen)
        }

        let passSegment = String(remainder[remainder.startIndex..<crossIndex])
        let failSegment = String(remainder[crossIndex...])

        return Text(prefix).font(font).foregroundColor(baseColor)
            + Text(passSegment).font(font).foregroundColor(Color.appGreen)
            + Text(failSegment).font(font).foregroundColor(Color.appRed)
    }
}
