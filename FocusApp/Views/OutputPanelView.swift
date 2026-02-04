import SwiftUI

struct OutputPanelView: View {
    let output: String
    let error: String
    let testCases: [TestCase]
    let isRunning: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(L10n.Output.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                if isRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 12, height: 12)
                        Text(L10n.Output.running)
                            .font(.system(size: 11))
                            .foregroundColor(Color.appGray400)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray800)

            Divider()
                .background(Color.appGray700)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
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
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.appGray900)
        }
    }
}
