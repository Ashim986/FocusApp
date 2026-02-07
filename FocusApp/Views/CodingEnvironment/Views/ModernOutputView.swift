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
                                .foregroundColor(selectedTab == tab ? .white : Color.appGray500)
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
                            .foregroundColor(Color.appGray500)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .padding(.trailing, 12)
                }
            }
            .background(Color.appGray800)
            .overlay(
                Rectangle()
                    .fill(Color.appGray700)
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
            .background(Color.appGray900)
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
            return Color.appRed
        }
        if allTestsPassed {
            return Color.appGreen
        }
        return Color.appAmber
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
