import SwiftUI

enum ProblemDetailTab: String, CaseIterable {
    case description = "Description"
    case editorial = "Editorial"
    case submissions = "Submissions"

    var icon: String {
        switch self {
        case .description:
            return "doc.text"
        case .editorial:
            return "lightbulb"
        case .submissions:
            return "clock.arrow.circlepath"
        }
    }
}

extension CodingEnvironmentView {
    @ViewBuilder
    var descriptionContent: some View {
        if presenter.isLoadingProblem {
            VStack(spacing: 10) {
                ProgressView()
                Text("Loading problem details...")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let content = presenter.problemContent {
            VStack(alignment: .leading, spacing: 12) {
                Text(attributedDescription(from: content.content))
                    .font(.system(size: 18))
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
                Text("Problem description will appear here.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    var editorialContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            solutionSection(title: "Intuition") {
                Text("Explain the key insight that makes the solution work.")
            }

            solutionSection(title: "Approach") {
                Text("Outline the steps and why each step is necessary.")
            }

            solutionSection(title: "Visual Diagram") {
                Text("[step 1] -> [step 2] -> [step 3]")
                    .font(.system(size: 11, design: .monospaced))
            }

            solutionSection(title: "Test Walkthrough") {
                walkthroughContent
            }

            solutionSection(title: "Big O") {
                Text("Time: O(?)   Space: O(?)")
                    .font(.system(size: 11, design: .monospaced))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    var pastSubmissionsContent: some View {
        if let problem = presenter.selectedProblem {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { lang in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(lang.rawValue) Submission")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)

                        if let code = presenter.loadStoredCode(for: problem, language: lang),
                           !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            codeBlock(code)
                        } else {
                            Text("No saved code yet.")
                                .font(.system(size: 11))
                                .foregroundColor(Color.appGray500)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appGray800.opacity(0.6))
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("Select a problem to view past submissions.")
                .font(.system(size: 11))
                .foregroundColor(Color.appGray500)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private var walkthroughContent: some View {
        if presenter.testCases.isEmpty {
            Text("Add at least two test cases to document a walkthrough.")
        } else {
            let cases = presenter.testCases.prefix(2)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(cases.enumerated()), id: \.offset) { index, testCase in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Case \(index + 1)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray400)

                        Text("Input: \(testCase.input)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.appGray200)

                        Text("Expected: \(testCase.expectedOutput)")
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

    private func attributedDescription(from html: String) -> AttributedString {
        let styledHTML = """
        <style>
        body { font-family: -apple-system; font-size: 18px; line-height: 1.6; color: #E6EDF8; }
        p, li { font-size: 18px; }
        h1, h2, h3, h4 { color: #FFFFFF; font-size: 20px; margin: 0 0 8px 0; }
        strong { color: #F9FAFB; }
        pre, code { font-family: Menlo, monospace; font-size: 16px; line-height: 1.5; }
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
            return AttributedString(attributed)
        }
        return AttributedString(html)
    }
}
