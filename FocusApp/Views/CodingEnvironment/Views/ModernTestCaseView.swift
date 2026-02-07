import FocusDesignSystem
import SwiftUI

struct ModernTestCaseView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @Binding var isCollapsed: Bool
    @State private var selectedTestIndex: Int = 0
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(spacing: DSLayout.spacing(0)) {
            HStack(spacing: DSLayout.spacing(0)) {
            Text(L10n.Coding.Testcase.title)
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)
                    .padding(.horizontal, DSLayout.spacing(12))
                    .padding(.vertical, DSLayout.spacing(8))

                Spacer()

                HStack(spacing: DSLayout.spacing(6)) {
                    headerIconButton(
                        title: L10n.Coding.Testcase.add,
                        systemName: "plus",
                        action: presenter.addManualTestCase
                    )
                    headerIconButton(
                        title: isCollapsed ? "Expand" : "Collapse",
                        systemName: isCollapsed ? "chevron.up" : "chevron.down",
                        action: { isCollapsed.toggle() }
                    )
                }
                .padding(.trailing, DSLayout.spacing(12))
            }
            .background(theme.colors.surfaceElevated)
            .overlay(
                Rectangle()
                    .fill(theme.colors.border)
                    .frame(height: 1),
                alignment: .bottom
            )

            if isCollapsed {
                EmptyView()
            } else if presenter.testCases.isEmpty {
                VStack(spacing: DSLayout.spacing(8)) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundColor(theme.colors.textSecondary)
                Text(L10n.Coding.Testcase.empty)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                    DSButton(
                        L10n.Coding.Testcase.add,
                        config: .init(style: .ghost, size: .small),
                        action: presenter.addManualTestCase
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.colors.surface)
            } else {
                VStack(spacing: DSLayout.spacing(0)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSLayout.spacing(4)) {
                            ForEach(Array(presenter.testCases.enumerated()), id: \.element.id) { index, testCase in
                                testCaseTab(index: index, testCase: testCase)
                            }
                        }
                        .padding(.horizontal, DSLayout.spacing(8))
                        .padding(.vertical, DSLayout.spacing(6))
                    }
                    .background(theme.colors.surface)

                    if selectedTestIndex < presenter.testCases.count {
                        testCaseContent(index: selectedTestIndex)
                    }
                }
            }
        }
        .frame(height: isCollapsed ? 36 : 180)
        .onChange(of: presenter.testCases.map(\.id)) { _, _ in
            if selectedTestIndex >= presenter.testCases.count {
                selectedTestIndex = 0
            }
        }
        .onChange(of: presenter.selectedProblem?.id) { _, _ in
            selectedTestIndex = 0
        }
    }

    private func testCaseTab(index: Int, testCase: TestCase) -> some View {
        let isSelected = selectedTestIndex == index

        return DSActionButton(action: {
            selectedTestIndex = index
            presenter.showJourneyForTestCase(index)
        }) {
            HStack(spacing: DSLayout.spacing(4)) {
                if let passed = testCase.passed {
                    Circle()
                        .fill(passed ? theme.colors.success : theme.colors.danger)
                        .frame(width: 6, height: 6)
                }

                Text(L10n.Coding.Testcase.caseFormat(index + 1))
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
            }
            .padding(.horizontal, DSLayout.spacing(10))
            .padding(.vertical, DSLayout.spacing(5))
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? theme.colors.surfaceElevated : Color.clear)
            )
        }
        .contextMenu {
            DSButton(
                "Delete",
                config: DSButtonConfig(style: .destructive, size: .small)
            ) {
                presenter.removeTestCase(at: index)
            }
        }
    }

    private func testCaseContent(index: Int) -> some View {
        guard presenter.testCases.indices.contains(index) else {
            return AnyView(EmptyView())
        }
        let testCase = presenter.testCases[index]

        return AnyView(ScrollView {
            VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                    Text(L10n.Coding.Testcase.inputLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.colors.textSecondary)

                    DSTextArea(
                        placeholder: "Enter input...",
                        text: Binding(
                            get: { testCase.input },
                            set: { presenter.updateTestCaseInput(at: index, input: $0) }
                        ),
                        config: DSTextAreaConfig(minHeight: 90, isResizable: true)
                    )
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                    HStack(spacing: DSLayout.spacing(4)) {
                        Text(L10n.Coding.Testcase.expectedLabel)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)

                        if testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("(unavailable)")
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(theme.colors.textSecondary)
                                .italic()
                        }
                    }

                    DSTextArea(
                        placeholder: "Enter expected output...",
                        text: Binding(
                            get: { testCase.expectedOutput },
                            set: { presenter.updateTestCaseExpectedOutput(at: index, output: $0) }
                        ),
                        config: DSTextAreaConfig(minHeight: 90, isResizable: true)
                    )
                }
            }
            .padding(DSLayout.spacing(10))
        }
        .background(theme.colors.surface))
    }

    private func headerIconButton(title: String, systemName: String, action: @escaping () -> Void) -> some View {
        DSButton(
            title,
            config: .init(
                style: .secondary,
                size: .small,
                icon: Image(systemName: systemName),
                iconPosition: .leading
            ),
            action: action
        )
    }
}
