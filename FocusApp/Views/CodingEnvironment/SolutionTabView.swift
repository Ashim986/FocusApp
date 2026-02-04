import SwiftUI

struct SolutionTabView: View {
    let solution: ProblemSolution?
    @State private var selectedApproachIndex: Int = 0
    @State private var expandedSections: Set<SolutionSection> = [.intuition, .approach]

    enum SolutionSection: String, CaseIterable {
        case intuition
        case approach
        case code
        case explanation
        case complexity
        case testCases
    }

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
                .font(.system(size: 13))
                .foregroundColor(Color.appGray500)
            Text(L10n.Coding.Solution.emptyHint)
                .font(.system(size: 11))
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
                approachDetail(approach)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Summary Card

    private func summaryCard(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.appAmber)
                Text(L10n.Coding.Solution.summaryTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(summary)
                .font(.system(size: 12))
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
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))

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
            .font(.system(size: 9, weight: .medium, design: .monospaced))
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

    private func approachDetail(_ approach: SolutionApproach) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            collapsibleSection(
                title: L10n.Coding.Solution.intuitionTitle,
                icon: "brain.head.profile",
                section: .intuition
            ) {
                Text(approach.intuition)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray300)
                    .lineSpacing(3)
            }

            collapsibleSection(
                title: L10n.Coding.Solution.approachTitle,
                icon: "arrow.triangle.branch",
                section: .approach
            ) {
                Text(approach.approach)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray300)
                    .lineSpacing(3)
            }

            collapsibleSection(
                title: L10n.Coding.Solution.codeTitle,
                icon: "chevron.left.forwardslash.chevron.right",
                section: .code
            ) {
                codeBlock(approach.code)
            }

            collapsibleSection(
                title: L10n.Coding.Solution.explanationTitle,
                icon: "text.alignleft",
                section: .explanation
            ) {
                Text(approach.explanation)
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray300)
                    .lineSpacing(3)
            }

            collapsibleSection(
                title: L10n.Coding.Solution.complexityTitle,
                icon: "chart.line.uptrend.xyaxis",
                section: .complexity
            ) {
                complexityDetail(approach.complexity)
            }

            if !approach.testCases.isEmpty {
                collapsibleSection(
                    title: L10n.Coding.Solution.testCasesTitle,
                    icon: "checklist",
                    section: .testCases
                ) {
                    testCasesContent(approach.testCases)
                }
            }
        }
    }

    // MARK: - Collapsible Section

    private func collapsibleSection<Content: View>(
        title: String,
        icon: String,
        section: SolutionSection,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                        .foregroundColor(Color.appPurple)
                        .frame(width: 16)

                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Image(systemName: expandedSections.contains(section) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.appGray500)
                }
                .padding(10)
                .background(Color.appGray800.opacity(0.6))
            }
            .buttonStyle(.plain)

            if expandedSections.contains(section) {
                content()
                    .padding(12)
                    .background(Color.appGray900.opacity(0.5))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.appGray700, lineWidth: 1)
        )
    }

    // MARK: - Code Block

    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Swift")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray400)

                Spacer()

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                        Text(L10n.Coding.Solution.copyCode)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(Color.appGray400)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appGray700.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }

            ScrollView {
                Text(code)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.appGray200)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 300)
        }
        .padding(10)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Complexity Detail

    private func complexityDetail(_ complexity: ComplexityAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            complexityRow(
                title: L10n.Coding.Solution.timeComplexity,
                value: complexity.time,
                explanation: complexity.timeExplanation,
                color: Color.appGreen
            )

            complexityRow(
                title: L10n.Coding.Solution.spaceComplexity,
                value: complexity.space,
                explanation: complexity.spaceExplanation,
                color: Color.appCyan
            )
        }
    }

    private func complexityRow(
        title: String,
        value: String,
        explanation: String?,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.appGray400)

                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(color)
            }

            if let explanation = explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
            }
        }
    }

    // MARK: - Test Cases

    private func testCasesContent(_ testCases: [SolutionTestCase]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(testCases.enumerated()), id: \.element.id) { index, testCase in
                testCaseRow(testCase, index: index)
            }
        }
    }

    private func testCaseRow(_ testCase: SolutionTestCase, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Coding.Solution.testCaseLabel( index + 1))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.appGray400)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Coding.Solution.inputLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.appAmber)
                    Text(testCase.input)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.appGray200)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Coding.Solution.outputLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.appGreen)
                    Text(testCase.expectedOutput)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.appGray200)
                }
            }

            if let explanation = testCase.explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
                    .padding(.top, 4)
            }
        }
        .padding(10)
        .background(Color.appGray800.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
