import Foundation

extension CodingEnvironmentPresenter {
    func loadProblemContent(for problem: Problem) async {
        let requestID = UUID()
        activeContentRequestID = requestID
        activeProblemSlug = LeetCodeSlugExtractor.extractSlug(from: problem.url)
        await loadProblemContent(for: problem, requestID: requestID)
    }

    func loadProblemContent(for problem: Problem, requestID: UUID) async {
        guard let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url) else {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .warning,
                    category: .app,
                    title: "Slug extraction failed",
                    message: "Unable to parse problem slug",
                    metadata: ["url": problem.url]
                )
            )
            return
        }

        if let cached = problemContentCache[slug] {
            await MainActor.run {
                guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
                self.problemContent = cached
                self.parseTestCases(from: cached)
                self.applySnippetIfNeeded(from: cached)
                self.isLoadingProblem = false
            }
            return
        }

        await MainActor.run {
            guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
            isLoadingProblem = true
        }

        do {
            let content = try await interactor.fetchProblemContent(slug: slug)
            if let content {
                problemContentCache[slug] = content
            } else {
                logger?.recordAsync(
                    DebugLogEntry(
                        level: .warning,
                        category: .network,
                        title: "Problem content missing",
                        message: "No content returned for slug",
                        metadata: ["slug": slug]
                    )
                )
            }
            await MainActor.run {
                guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
                self.problemContent = content
                if let content {
                    self.parseTestCases(from: content)
                    self.applySnippetIfNeeded(from: content)
                }
                self.isLoadingProblem = false
            }
        } catch {
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .network,
                    title: "Problem content fetch failed",
                    message: "Failed to load problem content",
                    metadata: [
                        "slug": slug,
                        "error": error.localizedDescription
                    ]
                )
            )
            await MainActor.run {
                guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
                self.isLoadingProblem = false
            }
        }
    }

    func parseTestCases(from content: QuestionContent) {
        let inputs = content.exampleTestcases.components(separatedBy: "\n").filter { !$0.isEmpty }
        let outputs = parseOutputsFromHTML(content.content)
        let meta = LeetCodeMetaData.decode(from: content.metaData)

        var cases: [TestCase] = []
        if let meta, !meta.isClassDesign, !meta.primaryParams.isEmpty {
            let groupedInputs = groupInputs(inputs, size: meta.primaryParams.count)
            for index in 0..<min(groupedInputs.count, max(outputs.count, 1)) {
                let input = groupedInputs.indices.contains(index) ? groupedInputs[index] : ""
                let output = outputs.indices.contains(index) ? outputs[index] : "Expected output"
                cases.append(TestCase(input: input, expectedOutput: output))
            }
        } else {
            for index in 0..<min(inputs.count, max(outputs.count, 1)) {
                let input = inputs.indices.contains(index) ? inputs[index] : ""
                let output = outputs.indices.contains(index) ? outputs[index] : "Expected output"
                cases.append(TestCase(input: input, expectedOutput: output))
            }
        }

        if cases.isEmpty && !content.sampleTestCase.isEmpty {
            cases.append(TestCase(input: content.sampleTestCase, expectedOutput: "Expected output"))
        }

        testCases = cases
    }

    private func groupInputs(_ inputs: [String], size: Int) -> [String] {
        guard size > 0 else { return inputs }
        var grouped: [String] = []
        var index = 0
        while index < inputs.count {
            let endIndex = min(index + size, inputs.count)
            let group = inputs[index..<endIndex]
            if group.count < size { break }
            grouped.append(group.joined(separator: "\n"))
            index = endIndex
        }
        return grouped
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

    private func shouldApplyContent(slug: String, requestID: UUID) -> Bool {
        guard requestID == activeContentRequestID else { return false }
        guard activeProblemSlug == slug else { return false }
        if let selected = selectedProblem {
            return LeetCodeSlugExtractor.extractSlug(from: selected.url) == slug
        }
        return true
    }
}
