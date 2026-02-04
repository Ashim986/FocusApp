import AppKit
import SwiftUI

struct SolutionApproachView: View {
    let approach: SolutionApproach

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

            CodeEditorView(
                code: .constant(code),
                language: .swift,
                diagnostics: [],
                isEditable: false,
                showsLineNumbers: false
            )
            .frame(minHeight: 220, maxHeight: 320)
            .clipShape(RoundedRectangle(cornerRadius: 6))
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
            Text(L10n.Coding.Solution.testCaseLabel(index + 1))
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
