import FocusDesignSystem
import SwiftUI

struct SolutionTabView: View {
    let solution: ProblemSolution?
    @State private var selectedApproachIndex: Int = 0
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let solution = solution {
                solutionContent(solution)
            } else {
                emptySolutionView
            }
        }
    }

    // MARK: - Empty State

    private var emptySolutionView: some View {
        VStack(spacing: 12) {
            DSImage(systemName: "checkmark.seal")
                .font(.system(size: 28))
                .foregroundColor(theme.colors.textSecondary)
            DSText(L10n.Coding.Solution.empty)
                .font(.system(size: 15))
                .foregroundColor(theme.colors.textSecondary)
            DSText(L10n.Coding.Solution.emptyHint)
                .font(.system(size: 13))
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Solution Content

    private func solutionContent(_ solution: ProblemSolution) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            summaryCard(solution.summary)

            if solution.approaches.count > 1 {
                approachSelector(solution.sortedApproaches)
            }

            if let approach = selectedApproach(from: solution) {
                SolutionApproachView(approach: approach)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Summary Card

    private func summaryCard(_ summary: String) -> some View {
        DSCard(config: .init(style: .outlined, padding: 12, cornerRadius: 10)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    DSImage(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.warning)
                    DSText(L10n.Coding.Solution.summaryTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                }

                DSText(summary)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Approach Selector

    private func approachSelector(_ approaches: [SolutionApproach]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(approaches.enumerated()), id: \.element.id) { index, approach in
                    approachPill(approach, isSelected: index == selectedApproachIndex) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedApproachIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func approachPill(
        _ approach: SolutionApproach,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        DSButton(action: action) {
            HStack(spacing: 6) {
                DSText(approach.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))

                complexityBadge(approach.complexity.time)
            }
            .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? theme.colors.primary.opacity(0.2) : theme.colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? theme.colors.primary : theme.colors.border,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func complexityBadge(_ complexity: String) -> some View {
        DSBadge(complexity, config: .init(style: .success))
    }

    // MARK: - Approach Detail

    private func selectedApproach(from solution: ProblemSolution) -> SolutionApproach? {
        let sorted = solution.sortedApproaches
        guard sorted.indices.contains(selectedApproachIndex) else {
            return sorted.first
        }
        return sorted[selectedApproachIndex]
    }
}
