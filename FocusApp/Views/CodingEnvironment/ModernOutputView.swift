import SwiftUI

struct ModernOutputView: View {
    let output: String
    let error: String
    let testCases: [TestCase]
    let isRunning: Bool

    @State private var selectedTab: OutputTab = .result

    enum OutputTab: String, CaseIterable {
        case result = "Result"
        case output = "Output"
        case debug = "Debug"
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(OutputTab.allCases, id: \.rawValue) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack(spacing: 4) {
                            if tab == .result && hasTestResults {
                                Circle()
                                    .fill(allTestsPassed ? Color.appGreen : Color.appRed)
                                    .frame(width: 6, height: 6)
                            }

                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? .white : Color.appGray500)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if isRunning {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(width: 12, height: 12)
                        Text("Running...")
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
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
                case .output:
                    outputContent
                case .debug:
                    debugContent
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appGray900)
        }
    }

    var hasTestResults: Bool {
        testCases.contains { $0.passed != nil }
    }

    var allTestsPassed: Bool {
        testCases.allSatisfy { $0.passed == true }
    }
}
