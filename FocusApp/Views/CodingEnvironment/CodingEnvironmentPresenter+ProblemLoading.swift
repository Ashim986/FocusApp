import Foundation

extension CodingEnvironmentPresenter {
    func loadProblemContent(for problem: Problem) async {
        guard let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            return
        }

        if let cached = problemContentCache[slug] {
            await MainActor.run {
                self.problemContent = cached
                self.parseTestCases(from: cached)
                self.applySnippetIfNeeded(from: cached)
            }
            return
        }

        await MainActor.run {
            isLoadingProblem = true
        }

        do {
            if let content = try await interactor.fetchProblemContent(slug: slug) {
                problemContentCache[slug] = content
                await MainActor.run {
                    self.problemContent = content
                    self.parseTestCases(from: content)
                    self.applySnippetIfNeeded(from: content)
                    self.isLoadingProblem = false
                }
            }
        } catch {
            await MainActor.run {
                self.isLoadingProblem = false
            }
        }
    }

    func parseTestCases(from content: QuestionContent) {
        let inputs = content.exampleTestcases.components(separatedBy: "\n").filter { !$0.isEmpty }
        let outputs = parseOutputsFromHTML(content.content)

        var cases: [TestCase] = []
        for i in 0..<min(inputs.count, max(outputs.count, 1)) {
            let input = inputs.indices.contains(i) ? inputs[i] : ""
            let output = outputs.indices.contains(i) ? outputs[i] : "Expected output"
            cases.append(TestCase(input: input, expectedOutput: output))
        }

        if cases.isEmpty && !content.sampleTestCase.isEmpty {
            cases.append(TestCase(input: content.sampleTestCase, expectedOutput: "Expected output"))
        }

        testCases = cases
    }

    func parseOutputsFromHTML(_ html: String) -> [String] {
        var outputs: [String] = []

        let pattern = "<strong>Output:</strong>\\s*([^<]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return outputs
        }

        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        for match in matches {
            if let range = Range(match.range(at: 1), in: html) {
                let output = String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                outputs.append(output)
            }
        }

        return outputs
    }
}
