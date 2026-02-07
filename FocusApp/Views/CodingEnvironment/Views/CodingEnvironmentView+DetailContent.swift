import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    @ViewBuilder
    var descriptionContent: some View {
        if presenter.isLoadingProblem {
            VStack(spacing: 10) {
                ProgressView()
                DSText(L10n.Coding.loadingProblem)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let content = presenter.problemContent {
            VStack(alignment: .leading, spacing: 12) {
                DSText(attributedDescription(from: content.content))
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textPrimary)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 8) {
                DSImage(systemName: "doc.text")
                    .font(.system(size: 22))
                    .foregroundColor(theme.colors.textSecondary)
                DSText(L10n.Coding.descriptionEmpty)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    var editorialContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            solutionSection(title: L10n.Coding.editorialVisualTitle) {
                DataJourneyView(
                    events: presenter.dataJourney,
                    selectedEventID: $presenter.selectedJourneyEventID,
                    onSelectEvent: { event in
                        presenter.selectJourneyEvent(event)
                    },
                    isTruncated: presenter.isJourneyTruncated
                )
            }

            solutionSection(title: L10n.Coding.editorialWalkthroughTitle) {
                walkthroughContent
            }

            solutionSection(title: L10n.Coding.editorialIntuitionTitle) {
                DSText(L10n.Coding.editorialIntuitionBody)
            }

            solutionSection(title: L10n.Coding.editorialApproachTitle) {
                DSText(L10n.Coding.editorialApproachBody)
            }

            solutionSection(title: L10n.Coding.editorialBigOTitle) {
                DSText(L10n.Coding.editorialBigOPlaceholder)
                    .font(.system(size: 11, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var pastSubmissionsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            hiddenTestsBadge

            if let problem = presenter.selectedProblem {
                let submissions = presenter.submissions(for: problem)
                if submissions.isEmpty {
                    DSText(L10n.Coding.submissionsEmpty)
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(submissions) { submission in
                            submissionRow(submission, problem: problem)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                DSText(L10n.Coding.submissionsSelectPrompt)
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var hiddenTestsBadge: some View {
        HStack(spacing: 8) {
            DSImage(systemName: hiddenTestStatusIcon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(hiddenTestStatusColor)

            if presenter.isGeneratingHiddenTests {
                ProgressView()
                    .controlSize(.small)
                DSText("Generating hidden tests…")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            } else if !presenter.hiddenTestCases.isEmpty {
                DSText("\(presenter.hiddenTestCases.count) Hidden Tests Ready")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.success)
            } else {
                DSText("Hidden tests unavailable")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(hiddenTestStatusColor.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var hiddenTestStatusIcon: String {
        if presenter.isGeneratingHiddenTests { return "arrow.triangle.2.circlepath" }
        if !presenter.hiddenTestCases.isEmpty { return "checkmark.shield.fill" }
        return "shield.slash"
    }

    private var hiddenTestStatusColor: Color {
        if presenter.isGeneratingHiddenTests { return theme.colors.warning }
        if !presenter.hiddenTestCases.isEmpty { return theme.colors.success }
        return theme.colors.textSecondary
    }

    @ViewBuilder
    private var walkthroughContent: some View {
        if presenter.testCases.isEmpty {
            DSText(L10n.Coding.walkthroughEmpty)
        } else {
            let cases = presenter.testCases.prefix(2)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(cases.enumerated()), id: \.offset) { index, testCase in
                    VStack(alignment: .leading, spacing: 4) {
                        DSText(L10n.Coding.walkthroughCaseLabel( index + 1))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)

                        DSText(L10n.Coding.walkthroughInputFormat( testCase.input))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textPrimary)

                        DSText(L10n.Coding.walkthroughExpectedFormat( testCase.expectedOutput))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.success)
                    }
                }
            }
        }
    }

    private func solutionSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            DSText(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
            content()
                .font(.system(size: 11))
                .foregroundColor(theme.colors.textSecondary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated)
        )
    }

    private func codeBlock(_ code: String) -> some View {
        ScrollView {
            DSText(code)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(theme.colors.textPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 220)
        .padding(8)
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func submissionRow(_ submission: CodeSubmission, problem: Problem) -> some View {
        DisclosureGroup {
            codeBlock(submission.code)
        } label: {
            HStack {
                DSText(problem.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                DSBadge(
                    languageLabel(for: submission.languageSlug),
                    config: .init(style: .info)
                )

                Spacer()

                DSText(formatSubmissionDate(submission.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated)
        )
    }

    private func languageLabel(for slug: String) -> String {
        if let match = ProgrammingLanguage.allCases.first(where: { $0.langSlug == slug }) {
            return match.rawValue
        }
        return slug
    }

    private func formatSubmissionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }

    private func attributedDescription(from html: String) -> AttributedString {
        let styledHTML = """
        <style>
        body { font-family: -apple-system; font-size: 14px; line-height: 1.6; color: #E6EDF8; }
        p, li { font-size: 14px; }
        h1, h2, h3, h4 { color: #FFFFFF; font-size: 18px; margin: 0 0 8px 0; }
        strong { color: #F9FAFB; }
        pre, code { font-family: Menlo, monospace; font-size: 14px; line-height: 1.5; }
        </style>
        \(html)
        """
        guard let data = styledHTML.data(using: .utf8) else {
            return AttributedString(html)
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            let highlighted = highlightLabels(in: attributed)
            return AttributedString(highlighted)
        }
        return AttributedString(html)
    }

    private func highlightLabels(in attributed: NSAttributedString) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: attributed)
        let text = attributed.string as NSString

        func apply(_ label: String, color: NSColor) {
            var searchRange = NSRange(location: 0, length: text.length)
            while true {
                let found = text.range(of: label, options: [.caseInsensitive], range: searchRange)
                if found.location == NSNotFound { break }
                mutable.addAttributes([.foregroundColor: color], range: found)
                let nextLocation = found.location + found.length
                if nextLocation >= text.length { break }
                searchRange = NSRange(location: nextLocation, length: text.length - nextLocation)
            }
        }

        apply("Input:", color: NSColor(theme.colors.warning))
        apply("Output:", color: NSColor(theme.colors.success))
        apply("Explanation:", color: NSColor(theme.colors.primary))

        return mutable
    }
}
