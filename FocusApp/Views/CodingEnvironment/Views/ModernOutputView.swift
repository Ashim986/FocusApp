import FocusDesignSystem
import SwiftUI

struct ModernOutputView: View {
    let output: String
    let error: String
    let testCases: [TestCase]
    let diagnostics: [CodeEditorDiagnostic]
    let isRunning: Bool
    let hiddenTestsHaveFailures: Bool
    let debugEntries: [DebugLogEntry]
    let logAnchor: Date?

    @State private var selectedTab: OutputTab = .result
    @Environment(\.dsTheme) var theme

    enum OutputTab: CaseIterable {
        case result
        case console
        case debug

        var title: String {
            switch self {
            case .result:
                return L10n.Coding.Output.tabResult
            case .console:
                return "Console"
            case .debug:
                return L10n.Coding.Output.tabDebug
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(availableTabs, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }, label: {
                        HStack(spacing: 4) {
                            if tab == .result && hasTestResults {
                                Circle()
                                    .fill(resultIndicatorColor)
                                    .frame(width: 6, height: 6)
                            }

                            Text(tab.title)
                                .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(
                                    selectedTab == tab
                                        ? theme.colors.textPrimary
                                        : theme.colors.textSecondary
                                )
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    })
                    .buttonStyle(.plain)
                }

                Spacer()

                if isRunning {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 12, height: 12)
                        Text(output.isEmpty
                            ? L10n.Coding.Output.running
                            : output)
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.trailing, 12)
                }
            }
            .background(theme.colors.surfaceElevated)
            .overlay(
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(height: 1),
                alignment: .bottom
            )

            Group {
                switch selectedTab {
                case .result:
                    resultContent
                case .console:
                    outputContent
                case .debug:
                    debugContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.surface)
        }
        .onChange(of: availableTabs) { _ in
            if !availableTabs.contains(selectedTab) {
                selectedTab = .result
            }
        }
    }

    var hasTestResults: Bool {
        testCases.contains { $0.passed != nil }
    }

    var hasFailures: Bool {
        testCases.contains { $0.passed == false }
    }

    var hasPendingResults: Bool {
        testCases.contains { $0.passed == nil }
    }

    var allTestsPassed: Bool {
        !testCases.isEmpty && !hasFailures && !hasPendingResults
    }

    var resultIndicatorColor: Color {
        if hasFailures {
            return theme.colors.danger
        }
        if allTestsPassed {
            return theme.colors.success
        }
        return theme.colors.warning
    }

    private var availableTabs: [OutputTab] {
        if hasDebugData {
            return [.result, .console, .debug]
        }
        return [.result, .console]
    }

    private var hasDebugData: Bool {
        if !error.isEmpty || !diagnostics.isEmpty {
            return true
        }
        if let anchor = logAnchor {
            return debugEntries.contains { entry in
                entry.category == .execution && entry.timestamp >= anchor
            }
        }
        return debugEntries.contains { $0.category == .execution }
    }
}
