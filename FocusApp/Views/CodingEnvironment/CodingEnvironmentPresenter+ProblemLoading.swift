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

        if let cached = problemContentCache[slug],
           Date().timeIntervalSince(cached.timestamp) < Self.cacheTTL {
            await MainActor.run {
                guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
                self.problemContent = cached.content
                self.parseTestCases(from: cached.content)
                self.applySnippetIfNeeded(from: cached.content)
                self.isLoadingProblem = false
                if let cachedDescription = self.problemDescriptionCache[slug] {
                    self.problemDescriptionText = cachedDescription
                }
            }
            await ensureProblemDescriptionText(for: cached.content, slug: slug, requestID: requestID)
            if !cachedContentNeedsRefresh(cached.content) {
                return
            }
        }

        await MainActor.run {
            guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
            isLoadingProblem = true
        }

        do {
            let content = try await interactor.fetchProblemContent(slug: slug)
            if let content {
                problemContentCache[slug] = CachedContent(content: content, timestamp: Date())
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
            if let content {
                await ensureProblemDescriptionText(for: content, slug: slug, requestID: requestID)
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
                let output = outputs.indices.contains(index) ? outputs[index] : ""
                cases.append(TestCase(input: input, expectedOutput: output))
            }
        } else {
            for index in 0..<min(inputs.count, max(outputs.count, 1)) {
                let input = inputs.indices.contains(index) ? inputs[index] : ""
                let output = outputs.indices.contains(index) ? outputs[index] : ""
                cases.append(TestCase(input: input, expectedOutput: output))
            }
        }

        if cases.isEmpty && !content.sampleTestCase.isEmpty {
            cases.append(TestCase(input: content.sampleTestCase, expectedOutput: ""))
        }

        testCases = cases
        applySolutionTestCaseFallback()
    }

    func applySolutionTestCaseFallback() {
        guard !testCases.isEmpty else { return }
        guard let fallbackCases = currentSolution?.sortedApproaches.first?.testCases,
              !fallbackCases.isEmpty else { return }

        var updated: [TestCase] = []
        updated.reserveCapacity(testCases.count)

        for (index, testCase) in testCases.enumerated() {
            guard fallbackCases.indices.contains(index) else {
                updated.append(testCase)
                continue
            }
            let fallback = fallbackCases[index]
            let needsInput = isMissingInput(testCase.input)
            let needsOutput = isMissingOutput(testCase.expectedOutput)
            if needsInput || needsOutput {
                let input = needsInput ? fallback.input : testCase.input
                let output = needsOutput ? fallback.expectedOutput : testCase.expectedOutput
                var merged = TestCase(input: input, expectedOutput: output)
                merged.actualOutput = testCase.actualOutput
                merged.passed = testCase.passed
                updated.append(merged)
            } else {
                updated.append(testCase)
            }
        }

        testCases = updated
    }

    private func isMissingInput(_ input: String) -> Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func isMissingOutput(_ output: String) -> Bool {
        output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func groupInputs(_ inputs: [String], size: Int) -> [String] {
        guard size > 0 else { return inputs }
        var grouped: [String] = []
        var index = 0
        while index < inputs.count {
            let endIndex = min(index + size, inputs.count)
            let group = Array(inputs[index..<endIndex])
            if group.count < size {
                // Pad incomplete last group with empty strings instead of dropping it
                let padded = group + Array(repeating: "", count: size - group.count)
                grouped.append(padded.joined(separator: "\n"))
            } else {
                grouped.append(group.joined(separator: "\n"))
            }
            index = endIndex
        }
        return grouped
    }

    func parseOutputsFromHTML(_ html: String) -> [String] {
        let pattern = [
            "<strong>Output:</strong>\\s*",
            "(?:<pre[^>]*>\\s*<code[^>]*>|<pre[^>]*>|<code[^>]*>)?\\s*",
            "([\\s\\S]*?)\\s*",
            "(?:</code>\\s*</pre>|</pre>|</code>|</p>|(?=<strong>)|$)"
        ].joined()
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }

        var outputs: [String] = []
        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
        for match in matches {
            if let range = Range(match.range(at: 1), in: html) {
                let raw = String(html[range])
                let stripped = stripHTMLTags(raw)
                let decoded = decodeHTMLEntities(stripped)
                let trimmed = decoded.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    outputs.append(trimmed)
                }
            }
        }

        if !outputs.isEmpty {
            return outputs
        }

        return parseOutputsFromPlainText(html)
    }

    private func decodeHTMLEntities(_ text: String) -> String {
        var result = text
        let entities: [(String, String)] = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&#39;", "'"),
            ("&apos;", "'"),
            ("&nbsp;", " ")
        ]
        for (entity, replacement) in entities {
            result = result.replacingOccurrences(of: entity, with: replacement)
        }
        // Decode numeric entities like &#123;
        if let numericRegex = try? NSRegularExpression(pattern: "&#(\\d+);", options: []) {
            let nsResult = result as NSString
            let matches = numericRegex.matches(in: result, range: NSRange(location: 0, length: nsResult.length))
            for match in matches.reversed() {
                let codeString = nsResult.substring(with: match.range(at: 1))
                if let code = Int(codeString), let scalar = Unicode.Scalar(code) {
                    result = (result as NSString).replacingCharacters(
                        in: match.range,
                        with: String(Character(scalar))
                    )
                }
            }
        }
        return result
    }

    private func parseOutputsFromPlainText(_ html: String) -> [String] {
        let plain = decodeHTMLEntities(stripHTMLTags(html))
        let lines = plain.components(separatedBy: .newlines)
        var outputs: [String] = []

        var index = 0
        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespacesAndNewlines)
            if line.lowercased().hasPrefix("output:") {
                var value = line.dropFirst("output:".count)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if value.isEmpty {
                    var nextIndex = index + 1
                    while nextIndex < lines.count {
                        let nextLine = lines[nextIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                        if !nextLine.isEmpty {
                            value = nextLine
                            index = nextIndex
                            break
                        }
                        nextIndex += 1
                    }
                }
                if !value.isEmpty {
                    outputs.append(value)
                }
            }
            index += 1
        }

        return outputs
    }

    private func stripHTMLTags(_ text: String) -> String {
        let withLineBreaks = text.replacingOccurrences(
            of: "<br\\s*/?>",
            with: "\n",
            options: .regularExpression
        )
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: []) else {
            return withLineBreaks
        }
        return regex.stringByReplacingMatches(
            in: withLineBreaks,
            range: NSRange(withLineBreaks.startIndex..., in: withLineBreaks),
            withTemplate: ""
        )
    }

    func ensureProblemDescriptionText(
        for content: QuestionContent,
        slug: String,
        requestID: UUID
    ) async {
        if let cached = problemDescriptionCache[slug] {
            await MainActor.run {
                guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
                self.problemDescriptionText = cached
            }
            return
        }

        let html = content.content
        let parsingTask = Task.detached(priority: .utility) {
            CodingEnvironmentPresenter.plainTextDescription(fromHTML: html)
        }
        let text = await parsingTask.value

        await MainActor.run {
            guard shouldApplyContent(slug: slug, requestID: requestID) else { return }
            self.problemDescriptionCache[slug] = text
            self.problemDescriptionText = text
        }
    }

    nonisolated private static func plainTextDescription(fromHTML html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        if let attributed = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        ) {
            return attributed.string
                .replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return html
            .replacingOccurrences(
                of: "<[^>]+>",
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
