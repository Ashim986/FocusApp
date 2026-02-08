#if os(iOS)
import FocusDesignSystem
import SwiftUI

struct SolutionViewIOS: View {
    let solution: ProblemSolution?
    @State private var selectedApproachIndex: Int = 0
    @Environment(\.dsTheme) var theme

    var body: some View {
        if let solution = solution {
            solutionContent(solution)
        } else {
            emptySolutionView
        }
    }

    // MARK: - Empty State

    private var emptySolutionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 32))
                .foregroundColor(theme.colors.textSecondary)
            Text(L10n.Coding.Solution.empty)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
            Text(L10n.Coding.Solution.emptyHint)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.lg)
    }

    // MARK: - Solution Content

    private func solutionContent(_ solution: ProblemSolution) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            summaryCard(solution.summary)
            if solution.approaches.count > 1 { approachSelector(solution.sortedApproaches) }
            if let approach = selectedApproach(from: solution) { approachDetail(approach) }
        }
        .padding(theme.spacing.lg)
    }

    // MARK: - Summary Card

    private func summaryCard(_ summary: String) -> some View {
        DSCard(config: .init(style: .outlined, padding: 12, cornerRadius: 10)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill").font(.system(size: 14))
                        .foregroundColor(theme.colors.warning)
                    Text(L10n.Coding.Solution.summaryTitle).font(theme.typography.body)
                        .fontWeight(.semibold).foregroundColor(theme.colors.textPrimary)
                }
                Text(summary).font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary).lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Approach Selector

    private func approachSelector(_ approaches: [SolutionApproach]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(approaches.enumerated()), id: \.element.id) { index, approach in
                    let isSelected = index == selectedApproachIndex
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedApproachIndex = index }
                    } label: {
                        Text(approach.name)
                            .font(theme.typography.caption)
                            .fontWeight(isSelected ? .semibold : .medium)
                            .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? theme.colors.primary.opacity(0.2) : theme.colors.surfaceElevated)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? theme.colors.primary : theme.colors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Approach Detail

    private func approachDetail(_ approach: SolutionApproach) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            section(L10n.Coding.Solution.intuitionTitle, icon: "brain.head.profile") {
                sectionText(approach.intuition)
            }
            section(L10n.Coding.Solution.approachTitle, icon: "arrow.triangle.branch") {
                sectionText(approach.approach)
            }
            section(L10n.Coding.Solution.codeTitle, icon: "chevron.left.forwardslash.chevron.right") {
                codeBlock(approach.code)
            }
            section(L10n.Coding.Solution.complexityTitle, icon: "speedometer") {
                complexityContent(approach.complexity)
            }
            if !approach.testCases.isEmpty {
                section(L10n.Coding.Solution.testCasesTitle, icon: "checklist") {
                    testCasesContent(approach.testCases)
                }
            }
        }
    }

    private func sectionText(_ text: String) -> some View {
        Text(text).font(theme.typography.body)
            .foregroundColor(theme.colors.textSecondary).lineSpacing(3)
    }

    // MARK: - Disclosure Section

    private func section<C: View>(
        _ title: String, icon: String, @ViewBuilder content: @escaping () -> C
    ) -> some View {
        DisclosureGroup {
            content().padding(.top, 8)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 13))
                    .foregroundColor(theme.colors.primary).frame(width: 16)
                Text(title).font(theme.typography.body)
                    .fontWeight(.semibold).foregroundColor(theme.colors.textPrimary)
            }
        }
        .tint(theme.colors.textSecondary)
        .padding(12)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.colors.border, lineWidth: 1))
    }

    // MARK: - Code Block

    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Swift").font(theme.typography.caption).fontWeight(.semibold)
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()
                Button { UIPasteboard.general.string = code } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc").font(.system(size: 12))
                        Text(L10n.Coding.Solution.copyCode).font(theme.typography.caption).fontWeight(.medium)
                    }
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(theme.colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            ScrollView(.horizontal, showsIndicators: true) {
                Text(code).font(theme.typography.mono)
                    .foregroundColor(theme.colors.textPrimary).textSelection(.enabled)
            }
            .padding(10).background(theme.colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    // MARK: - Complexity

    private func complexityContent(_ complexity: ComplexityAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            complexityRow(L10n.Coding.Solution.timeComplexity, value: complexity.time,
                          style: .success, explanation: complexity.timeExplanation)
            complexityRow(L10n.Coding.Solution.spaceComplexity, value: complexity.space,
                          style: .neutral, explanation: complexity.spaceExplanation)
        }
    }

    private func complexityRow(
        _ title: String, value: String, style: DSBadgeStyle, explanation: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(title).font(theme.typography.caption).fontWeight(.medium)
                    .foregroundColor(theme.colors.textSecondary)
                DSBadge(value, config: .init(style: style))
            }
            if let explanation, !explanation.isEmpty {
                Text(explanation).font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
    }

    // MARK: - Test Cases

    private func testCasesContent(_ testCases: [SolutionTestCase]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, tc in
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.Coding.Solution.testCaseLabel(index + 1))
                        .font(theme.typography.caption).fontWeight(.semibold)
                        .foregroundColor(theme.colors.textSecondary)
                    HStack(spacing: 12) {
                        labeledMono(L10n.Coding.Solution.inputLabel, tc.input, theme.colors.warning)
                        labeledMono(L10n.Coding.Solution.outputLabel, tc.expectedOutput, theme.colors.success)
                    }
                    if let explanation = tc.explanation, !explanation.isEmpty {
                        Text(explanation).font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                .padding(10).background(theme.colors.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private func labeledMono(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(theme.typography.caption).fontWeight(.medium).foregroundColor(color)
            Text(value).font(theme.typography.mono).foregroundColor(theme.colors.textPrimary)
        }
    }

    // MARK: - Helpers

    private func selectedApproach(from solution: ProblemSolution) -> SolutionApproach? {
        let sorted = solution.sortedApproaches
        guard sorted.indices.contains(selectedApproachIndex) else { return sorted.first }
        return sorted[selectedApproachIndex]
    }
}
#endif
