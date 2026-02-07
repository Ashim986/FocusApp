import FocusDesignSystem
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
                        DSText(L10n.Coding.Output.running)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 14, height: 14)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !hasTestResults && output.isEmpty && error.isEmpty {
            VStack(spacing: 8) {
                DSImage(systemName: "play.circle")
                    .font(.system(size: 28))
                    .foregroundColor(theme.colors.textSecondary)
                DSText(L10n.Coding.Output.empty)
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
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
                        DSImage(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(theme.colors.danger)
                        DSText(L10n.Coding.Output.compilationError)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.colors.danger)
                    }

                    DSText(error)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(theme.colors.danger)
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
                DSImage(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(passed ? theme.colors.success : theme.colors.danger)

                DSText(L10n.Coding.Output.testFormat(index + 1))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                DSText(passed
                    ? L10n.Coding.Output.passed
                    : L10n.Coding.Output.failed)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(passed ? theme.colors.success : theme.colors.danger)
            }

            if !passed {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 4) {
                        DSText(L10n.Coding.Output.inputLabel)
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                            .frame(width: 60, alignment: .leading)
                        DSText(testCase.input)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textPrimary)
                    }

                    HStack(alignment: .top, spacing: 4) {
                        DSText(L10n.Coding.Output.expectedLabel)
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                            .frame(width: 60, alignment: .leading)
                        DSText(testCase.expectedOutput)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.success)
                    }

                    if let actual = testCase.actualOutput {
                        HStack(alignment: .top, spacing: 4) {
                            DSText(L10n.Coding.Output.outputLabel)
                                .font(.system(size: 10))
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 60, alignment: .leading)
                            DSText(actual)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(theme.colors.danger)
                        }
                    }
                }
                .padding(8)
                .background(theme.colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.colors.surfaceElevated.opacity(0.7))
        )
    }

    @ViewBuilder
    var outputContent: some View {
        if output.isEmpty {
            VStack(spacing: 8) {
                DSImage(systemName: "terminal")
                    .font(.system(size: 28))
                    .foregroundColor(theme.colors.textSecondary)
                DSText(L10n.Coding.Output.noOutput)
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
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
                DSImage(systemName: "ladybug")
                    .font(.system(size: 26))
                    .foregroundColor(theme.colors.textSecondary)
                DSText(L10n.Coding.Output.noDebug)
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if !diagnostics.isEmpty {
                        DSText("Diagnostics")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.danger)

                        VStack(spacing: 6) {
                            ForEach(diagnostics, id: \.self) { diagnostic in
                                diagnosticRow(diagnostic)
                            }
                        }
                        .padding(.bottom, 4)
                    }

                    if !error.isEmpty {
                        DSText(L10n.Coding.Output.stderrLabel)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.danger)

                        DSText(error)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(theme.colors.danger)
                            .textSelection(.enabled)
                            .padding(8)
                            .background(theme.colors.danger.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    if !executionEntries.isEmpty {
                        DSText(L10n.Debug.logsTitle)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
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
                DSText(diagnosticLocation(diagnostic))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(theme.colors.danger)
                DSText(diagnostic.message)
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textPrimary)
                    .textSelection(.enabled)
            }

            Spacer(minLength: 0)

            DSButton(
                action: { copyDiagnostic(diagnostic) },
                label: {
                    DSImage(systemName: "doc.on.doc")
                        .font(.system(size: 9))
                        .foregroundColor(theme.colors.textSecondary)
                }
            )
            .buttonStyle(.plain)
        }
        .padding(8)
        .background(theme.colors.danger.opacity(0.1))
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
    private func coloredProgressText(_ text: String) -> some View {
        let baseColor: Color = hiddenTestsHaveFailures
            ? theme.colors.danger.opacity(0.85)
            : theme.colors.success.opacity(0.85)
        let font = Font.system(size: 13, weight: .semibold)

        guard let checkIndex = text.firstIndex(of: "✓") else {
            return HStack(spacing: 0) {
                DSText(text).font(font).foregroundColor(baseColor)
            }
        }

        let prefix = String(text[text.startIndex..<checkIndex])
        let remainder = String(text[checkIndex...])

        guard let crossIndex = remainder.firstIndex(of: "✗") else {
            return HStack(spacing: 0) {
                DSText(prefix).font(font).foregroundColor(baseColor)
                DSText(remainder).font(font).foregroundColor(theme.colors.success)
            }
        }

        let passSegment = String(remainder[remainder.startIndex..<crossIndex])
        let failSegment = String(remainder[crossIndex...])

        return HStack(spacing: 0) {
            DSText(prefix).font(font).foregroundColor(baseColor)
            DSText(passSegment).font(font).foregroundColor(theme.colors.success)
            DSText(failSegment).font(font).foregroundColor(theme.colors.danger)
        }
    }
}
