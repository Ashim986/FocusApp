import SwiftUI

enum ProblemDetailTab: CaseIterable {
    case description
    case editorial
    case solution
    case submissions
    case debug

    var icon: String {
        switch self {
        case .description:
            return "doc.text"
        case .editorial:
            return "lightbulb"
        case .solution:
            return "checkmark.seal"
        case .submissions:
            return "clock.arrow.circlepath"
        case .debug:
            return "ladybug"
        }
    }

    var title: String {
        switch self {
        case .description:
            return L10n.Coding.tabDescription
        case .editorial:
            return L10n.Coding.tabEditorial
        case .solution:
            return L10n.Coding.tabSolution
        case .submissions:
            return L10n.Coding.tabSubmissions
        case .debug:
            return L10n.Coding.tabDebug
        }
    }
}

extension CodingEnvironmentView {
    @ViewBuilder
    var descriptionContent: some View {
        if presenter.isLoadingProblem {
            VStack(spacing: 10) {
                ProgressView()
                Text(L10n.Coding.loadingProblem)
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let content = presenter.problemContent {
            VStack(alignment: .leading, spacing: 12) {
                Text(attributedDescription(from: content.content))
                    .font(.system(size: 14))
                    .foregroundColor(Color.appGray50)
                    .lineSpacing(4)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 22))
                    .foregroundColor(Color.appGray600)
                Text(L10n.Coding.descriptionEmpty)
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    var editorialContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            solutionSection(title: L10n.Coding.editorialIntuitionTitle) {
                Text(L10n.Coding.editorialIntuitionBody)
            }

            solutionSection(title: L10n.Coding.editorialApproachTitle) {
                Text(L10n.Coding.editorialApproachBody)
            }

            solutionSection(title: L10n.Coding.editorialVisualTitle) {
                Text(L10n.Coding.editorialVisualPlaceholder)
                    .font(.system(size: 11, design: .monospaced))
            }

            solutionSection(title: L10n.Coding.editorialWalkthroughTitle) {
                walkthroughContent
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
        if let problem = presenter.selectedProblem {
            let submissions = presenter.submissions(for: problem)
            if submissions.isEmpty {
                Text(L10n.Coding.submissionsEmpty)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(submissions) { submission in
                        submissionRow(submission)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text(L10n.Coding.submissionsSelectPrompt)
                .font(.system(size: 11))
                .foregroundColor(Color.appGray500)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private var walkthroughContent: some View {
        if presenter.testCases.isEmpty {
            Text(L10n.Coding.walkthroughEmpty)
        } else {
            let cases = presenter.testCases.prefix(2)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(cases.enumerated()), id: \.offset) { index, testCase in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.Coding.walkthroughCaseLabel( index + 1))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray400)

                        Text(L10n.Coding.walkthroughInputFormat( testCase.input))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGray200)

                        Text(L10n.Coding.walkthroughExpectedFormat( testCase.expectedOutput))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGreen)
                    }
                }
            }
        }
    }

    private func solutionSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
            content()
                .font(.system(size: 11))
                .foregroundColor(Color.appGray300)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray800.opacity(0.6))
        )
    }

    private func codeBlock(_ code: String) -> some View {
        ScrollView {
            Text(code)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.appGray200)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 220)
        .padding(8)
        .background(Color.black.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func submissionRow(_ submission: CodeSubmission) -> some View {
        DisclosureGroup {
            codeBlock(submission.code)
        } label: {
            HStack {
                Text(languageLabel(for: submission.languageSlug))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)

                if let tag = submission.algorithmTag, !tag.isEmpty {
                    Text(tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.appPurple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.appPurple.opacity(0.15))
                        .clipShape(Capsule())
                }

                Spacer()

                Text(formatSubmissionDate(submission.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGray400)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray800.opacity(0.6))
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

        apply("Input:", color: NSColor(Color.appAmber))
        apply("Output:", color: NSColor(Color.appGreen))
        apply("Explanation:", color: NSColor(Color.appPurple))

        return mutable
    }
}
