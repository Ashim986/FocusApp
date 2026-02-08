#if os(macOS)
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

        var id: String {
            switch self {
            case .result:
                return "result"
            case .console:
                return "console"
            case .debug:
                return "debug"
            }
        }

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
        VStack(spacing: DSLayout.spacing(0)) {
            HStack(spacing: DSLayout.spacing(.space8)) {
                DSSegmentedControl(
                    items: availableTabs.map { tab in
                        DSSegmentItem(id: tab.id, title: tab.title)
                    },
                    state: .init(selectedId: selectedTab.id),
                    onSelect: { id in
                        if let tab = availableTabs.first(where: { $0.id == id }) {
                            selectedTab = tab
                        }
                    }
                )
                if isRunning {
                    HStack(spacing: DSLayout.spacing(.space4)) {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: DSLayout.spacing(.space12), height: DSLayout.spacing(.space12))
                        Text(output.isEmpty
                            ? L10n.Coding.Output.running
                            : output)
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.trailing, DSLayout.spacing(.space12))
                }
            }
            .padding(.horizontal, DSLayout.spacing(.space8))
            .padding(.vertical, DSLayout.spacing(.space8))
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
        .onChange(of: availableTabs) {
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

#endif
