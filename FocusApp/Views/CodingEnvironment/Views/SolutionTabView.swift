import SwiftUI

struct SolutionTabView: View {
    let solution: ProblemSolution?
    @State private var selectedApproachIndex: Int = 0

    var body: some View {
        if let solution = solution {
            solutionContent(solution)
        } else {
            emptySolutionView
        }
    }

    // MARK: - Empty State

    private var emptySolutionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 28))
                .foregroundColor(Color.appGray600)
            Text(L10n.Coding.Solution.empty)
                .font(.system(size: 15))
                .foregroundColor(Color.appGray500)
            Text(L10n.Coding.Solution.emptyHint)
                .font(.system(size: 13))
                .foregroundColor(Color.appGray600)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.appAmber)
                Text(L10n.Coding.Solution.summaryTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(summary)
                .font(.system(size: 14))
                .foregroundColor(Color.appGray300)
                .lineSpacing(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appGray800.opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.appAmber.opacity(0.3), lineWidth: 1)
                )
        )
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
        Button(action: action) {
            HStack(spacing: 6) {
                Text(approach.name)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))

                complexityBadge(approach.complexity.time)
            }
            .foregroundColor(isSelected ? .white : Color.appGray400)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appPurple.opacity(0.3) : Color.appGray800)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.appPurple : Color.appGray700,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func complexityBadge(_ complexity: String) -> some View {
        Text(complexity)
            .font(.system(size: 11, weight: .medium, design: .monospaced))
            .foregroundColor(Color.appGreen)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.appGreen.opacity(0.15))
            .clipShape(Capsule())
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
