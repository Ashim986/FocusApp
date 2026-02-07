import FocusDesignSystem
import SwiftUI

struct OutputPanelView: View {
    let output: String
    let error: String
    let testCases: [TestCase]
    let isRunning: Bool
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(0)) {
            // Header
            HStack {
                Text(L10n.Output.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                if isRunning {
                    HStack(spacing: DSLayout.spacing(6)) {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 12, height: 12)
                        Text(L10n.Output.running)
                            .font(.system(size: 11))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, DSLayout.spacing(12))
            .padding(.vertical, DSLayout.spacing(8))
            .background(theme.colors.surfaceElevated)

            Divider()
                .background(theme.colors.border)

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
                    // Test results
                    if !testCases.isEmpty {
                        testResultsSection
                    }

                    // Console output (stdout)
                    if !output.isEmpty {
                        consoleOutputSection
                    }

                    // Error output (stderr)
                    if !error.isEmpty {
                        errorSection
                    }

                    // Empty state
                    if output.isEmpty && error.isEmpty && testCases.allSatisfy({ $0.passed == nil }) {
                        emptyState
                    }
                }
                .padding(DSLayout.spacing(12))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(theme.colors.surface)
        }
    }
}
