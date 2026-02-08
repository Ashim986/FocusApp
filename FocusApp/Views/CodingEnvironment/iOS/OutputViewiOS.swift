#if os(iOS)
import FocusDesignSystem
import SwiftUI

struct OutputViewiOS: View {
    let output: String
    let error: String
    let testResults: [TestCase]
    let isRunning: Bool
    let hiddenTestProgress: String
    let hiddenTestsHaveFailures: Bool
    let diagnostics: [CodeEditorDiagnostic]
    let hasTestResults: Bool

    @State private var selectedTab: OutputTab = .result
    @Environment(\.dsTheme) var theme

    enum OutputTab: String, CaseIterable, Identifiable {
        case result, console, debug
        var id: String { rawValue }
        var title: String {
            switch self {
            case .result: return L10n.Coding.Output.tabResult
            case .console: return "Console"
            case .debug: return L10n.Coding.Output.tabDebug
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider().background(theme.colors.border)
            Group {
                switch selectedTab {
                case .result: resultContent
                case .console: consoleContent
                case .debug: debugContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.surface)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 8) {
            Picker("Tab", selection: $selectedTab) {
                ForEach(OutputTab.allCases) { tab in Text(tab.title).tag(tab) }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
            if isRunning {
                HStack(spacing: 4) {
                    ProgressView().scaleEffect(0.6).frame(width: 14, height: 14)
                    Text(output.isEmpty ? L10n.Coding.Output.running : output)
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(1).truncationMode(.tail)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(theme.colors.surfaceElevated)
    }

    // MARK: - Result Tab

    @ViewBuilder
    private var resultContent: some View {
        if isRunning, !hasTestResults {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    if !hiddenTestProgress.isEmpty {
                        coloredProgressText(hiddenTestProgress)
                    } else {
                        Text(L10n.Coding.Output.running)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    ProgressView().scaleEffect(0.7).frame(width: 14, height: 14)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !hasTestResults && output.isEmpty && error.isEmpty {
            emptyState(icon: "play.circle", text: L10n.Coding.Output.empty)
        } else if hasTestResults {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(testResults.enumerated()), id: \.element.id) { idx, tc in
                        if let passed = tc.passed {
                            testResultRow(index: idx, testCase: tc, passed: passed)
                        }
                    }
                }.padding(12)
            }
        } else if !error.isEmpty {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(theme.colors.danger)
                        Text(L10n.Coding.Output.compilationError)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.colors.danger)
                    }
                    Text(error)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(theme.colors.danger)
                        .textSelection(.enabled)
                }.padding(12)
            }
        } else { consoleContent }
    }

    // MARK: - Console Tab

    @ViewBuilder
    private var consoleContent: some View {
        if output.isEmpty {
            emptyState(icon: "terminal.fill", text: L10n.Coding.Output.noOutput)
        } else {
            ScrollView {
                let lines = output.components(separatedBy: "\n")
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                        HStack(alignment: .top, spacing: 0) {
                            Text("\(idx + 1)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 32, alignment: .trailing)
                                .padding(.trailing, 8)
                            Rectangle().fill(theme.colors.border).frame(width: 1).padding(.trailing, 8)
                            Text(line.isEmpty ? " " : line)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(theme.colors.textPrimary)
                                .textSelection(.enabled)
                            Spacer(minLength: 0)
                        }.padding(.vertical, 2)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.colors.surfaceElevated.opacity(0.6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(theme.colors.border, lineWidth: 1))
                )
                .padding(12)
            }
        }
    }

    // MARK: - Debug Tab

    @ViewBuilder
    private var debugContent: some View {
        if diagnostics.isEmpty && error.isEmpty {
            emptyState(icon: "ladybug", text: L10n.Coding.Output.noDebug)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if !diagnostics.isEmpty {
                        Text("Diagnostics")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.colors.danger)
                        ForEach(diagnostics, id: \.self) { diag in
                            diagnosticRow(diag)
                        }
                    }
                    if !error.isEmpty {
                        Text(L10n.Coding.Output.stderrLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(theme.colors.danger)
                            .padding(.top, diagnostics.isEmpty ? 0 : 6)
                        Text(error)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(theme.colors.danger)
                            .textSelection(.enabled)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(theme.colors.danger.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }.padding(12)
            }
        }
    }

    // MARK: - Subviews

    private func diagnosticRow(_ diagnostic: CodeEditorDiagnostic) -> some View {
        let loc = diagnostic.column.map { "Line \(diagnostic.line), Col \($0)" }
            ?? "Line \(diagnostic.line)"
        return VStack(alignment: .leading, spacing: 2) {
            Text(loc)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(theme.colors.danger)
            Text(diagnostic.message)
                .font(.system(size: 12))
                .foregroundColor(theme.colors.textPrimary)
                .textSelection(.enabled)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.danger.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func testResultRow(index: Int, testCase: TestCase, passed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(passed ? theme.colors.success : theme.colors.danger)
                Text(L10n.Coding.Output.testFormat(index + 1))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)
                Spacer()
                Text(passed ? L10n.Coding.Output.passed : L10n.Coding.Output.failed)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(passed ? theme.colors.success : theme.colors.danger)
            }
            if !passed {
                VStack(alignment: .leading, spacing: 6) {
                    labeledValue(L10n.Coding.Output.inputLabel, testCase.input, theme.colors.textPrimary)
                    labeledValue(L10n.Coding.Output.expectedLabel, testCase.expectedOutput, theme.colors.success)
                    if let actual = testCase.actualOutput {
                        labeledValue(L10n.Coding.Output.outputLabel, actual, theme.colors.danger)
                    }
                }
                .padding(8)
                .background(theme.colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 6).fill(theme.colors.surfaceElevated.opacity(0.7)))
    }

    // MARK: - Helpers

    private func labeledValue(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(label).font(.system(size: 11)).foregroundColor(theme.colors.textSecondary)
                .frame(width: 64, alignment: .leading)
            Text(value).font(.system(size: 11, design: .monospaced)).foregroundColor(color)
        }
    }

    private func emptyState(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 30)).foregroundColor(theme.colors.textSecondary)
            Text(text).font(.system(size: 13)).foregroundColor(theme.colors.textSecondary)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Colored Progress Text

    @ViewBuilder
    private func coloredProgressText(_ text: String) -> some View {
        let baseColor: Color = hiddenTestsHaveFailures
            ? theme.colors.danger.opacity(0.85) : theme.colors.success.opacity(0.85)
        let font = Font.system(size: 14, weight: .semibold)

        if let checkIdx = text.firstIndex(of: "\u{2713}") {
            let prefix = String(text[text.startIndex..<checkIdx])
            let remainder = String(text[checkIdx...])
            if let crossIdx = remainder.firstIndex(of: "\u{2717}") {
                let pass = String(remainder[remainder.startIndex..<crossIdx])
                let fail = String(remainder[crossIdx...])
                HStack(spacing: 0) {
                    Text(prefix).font(font).foregroundColor(baseColor)
                    Text(pass).font(font).foregroundColor(theme.colors.success)
                    Text(fail).font(font).foregroundColor(theme.colors.danger)
                }
            } else {
                HStack(spacing: 0) {
                    Text(prefix).font(font).foregroundColor(baseColor)
                    Text(remainder).font(font).foregroundColor(theme.colors.success)
                }
            }
        } else {
            Text(text).font(font).foregroundColor(baseColor)
        }
    }
}

#endif
