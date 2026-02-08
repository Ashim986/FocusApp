#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    @ViewBuilder
    var descriptionContent: some View {
        if presenter.isLoadingProblem {
            VStack(spacing: DSLayout.spacing(10)) {
                ProgressView()
                Text(L10n.Coding.loadingProblem)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let content = presenter.problemContent {
            VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
                Text(attributedDescription(from: content.content))
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.textPrimary)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: DSLayout.spacing(8)) {
                Image(systemName: "doc.text")
                    .font(.system(size: 22))
                    .foregroundColor(theme.colors.textSecondary)
                Text(L10n.Coding.descriptionEmpty)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    var editorialContent: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
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
                Text(L10n.Coding.editorialIntuitionBody)
            }

            solutionSection(title: L10n.Coding.editorialApproachTitle) {
                Text(L10n.Coding.editorialApproachBody)
            }

            solutionSection(title: L10n.Coding.editorialBigOTitle) {
                Text(L10n.Coding.editorialBigOPlaceholder)
                    .font(.system(size: 11, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var pastSubmissionsContent: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
            hiddenTestsBadge

            if let problem = presenter.selectedProblem {
                let submissions = presenter.submissions(for: problem)
                if submissions.isEmpty {
                    Text(L10n.Coding.submissionsEmpty)
                        .font(.system(size: 11))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
                        ForEach(submissions) { submission in
                            submissionRow(submission, problem: problem)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(L10n.Coding.submissionsSelectPrompt)
                    .font(.system(size: 11))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private var hiddenTestsBadge: some View {
        HStack(spacing: DSLayout.spacing(8)) {
            Image(systemName: hiddenTestStatusIcon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(hiddenTestStatusColor)

            if presenter.isGeneratingHiddenTests {
                ProgressView()
                    .controlSize(.small)
                Text("Generating hidden tests…")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            } else if !presenter.hiddenTestCases.isEmpty {
                Text("\(presenter.hiddenTestCases.count) Hidden Tests Ready")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.success)
            } else {
                Text("Hidden tests unavailable")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(DSLayout.spacing(10))
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
            Text(L10n.Coding.walkthroughEmpty)
        } else {
            let cases = presenter.testCases.prefix(2)
            VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
                ForEach(Array(cases.enumerated()), id: \.offset) { index, testCase in
                    VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                        Text(L10n.Coding.walkthroughCaseLabel( index + 1))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.colors.textSecondary)

                        Text(L10n.Coding.walkthroughInputFormat( testCase.input))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.textPrimary)

                        Text(L10n.Coding.walkthroughExpectedFormat( testCase.expectedOutput))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.colors.success)
                    }
                }
            }
        }
    }

    private func solutionSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
            content()
                .font(.system(size: 11))
                .foregroundColor(theme.colors.textSecondary)
        }
        .padding(DSLayout.spacing(10))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.colors.surfaceElevated)
        )
    }

    private func codeBlock(_ code: String) -> some View {
        ScrollView {
            Text(code)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(theme.colors.textPrimary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 220)
        .padding(DSLayout.spacing(8))
        .background(theme.colors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func submissionRow(_ submission: CodeSubmission, problem: Problem) -> some View {
        DisclosureGroup {
            codeBlock(submission.code)
        } label: {
            HStack {
                Text(problem.displayName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                DSBadge(
                    languageLabel(for: submission.languageSlug),
                    config: .init(style: .info)
                )

                Spacer()

                Text(formatSubmissionDate(submission.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
        .padding(DSLayout.spacing(10))
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

#endif
