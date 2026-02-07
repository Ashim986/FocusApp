import AppKit
import FocusDesignSystem
import SwiftUI

struct SolutionApproachView: View {
    let approach: SolutionApproach

    @State private var expandedSections: Set<SolutionSection> = [.intuition, .approach]
    @Environment(\.dsTheme) var theme

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
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
                    .lineSpacing(3)
            }

            collapsibleSection(
                title: L10n.Coding.Solution.approachTitle,
                icon: "arrow.triangle.branch",
                section: .approach
            ) {
                Text(approach.approach)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
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
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textSecondary)
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
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.primary)
                        .frame(width: 16)

                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Image(systemName: expandedSections.contains(section) ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .padding(10)
                .background(theme.colors.surfaceElevated)
            }
            .buttonStyle(.plain)

            if expandedSections.contains(section) {
                content()
                    .padding(12)
                    .background(theme.colors.surface)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }

    // MARK: - Code Block

    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Swift")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                        Text(L10n.Coding.Solution.copyCode)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.colors.surfaceElevated)
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
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Complexity Detail

    private func complexityDetail(_ complexity: ComplexityAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            complexityRow(
                title: L10n.Coding.Solution.timeComplexity,
                value: complexity.time,
                explanation: complexity.timeExplanation,
                color: theme.colors.success
            )

            complexityRow(
                title: L10n.Coding.Solution.spaceComplexity,
                value: complexity.space,
                explanation: complexity.spaceExplanation,
                color: theme.colors.accent
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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)

                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(color)
            }

            if let explanation = explanation, !explanation.isEmpty {
                Text(explanation)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
    }

}
