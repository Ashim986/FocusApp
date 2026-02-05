import Foundation

extension CodingEnvironmentPresenter {
    func selectProblem(_ item: CodingProblemItem) {
        selectProblem(item.problem, at: item.index, day: item.dayId)
    }

    func initialCode(for problem: Problem, language: ProgrammingLanguage) -> String {
        if let storedCode = loadStoredCode(for: problem, language: language) {
            let trimmed = storedCode.trimmingCharacters(in: .whitespacesAndNewlines)
            let defaultTrimmed = language.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed != defaultTrimmed {
                if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
                   let cached = problemContentCache[slug],
                   !isStoredCodeCompatible(storedCode, with: cached, language: language) {
                    // Ignore stale code that doesn't match the current problem signature.
                } else {
                    return storedCode
                }
            }
        }

        if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
           let cached = problemContentCache[slug],
           let snippet = snippetForLanguage(language, from: cached) {
            return snippet
        }

        if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
           let cached = problemContentCache[slug],
           let template = LeetCodeTemplateBuilder.template(for: cached, language: language) {
            return template
        }

        return ""
    }

    func applySnippetIfNeeded(from content: QuestionContent) {
        guard let problem = selectedProblem else { return }
        let defaultTrimmed = language.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        if let storedCode = loadStoredCode(for: problem, language: language) {
            let trimmed = storedCode.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed != defaultTrimmed {
                if isStoredCodeCompatible(storedCode, with: content, language: language) {
                    return
                }
                // Clear incompatible stored code so it doesn't keep reappearing.
                interactor.saveSolution(code: "", for: solutionKey(for: problem, language: language))
                announceCodeReset("Stored code didn't match this problem's signature. Reset to template.")
            }
        }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != defaultTrimmed {
            return
        }
        if let snippet = snippetForLanguage(language, from: content) {
            setCode(snippet)
            return
        }
        if let template = LeetCodeTemplateBuilder.template(for: content, language: language) {
            setCode(template)
        }
    }

    func snippetForLanguage(_ language: ProgrammingLanguage, from content: QuestionContent) -> String? {
        for slug in language.snippetSlugs {
            if let snippet = content.codeSnippets[slug] {
                return snippet
            }
        }
        return nil
    }

    private func isStoredCodeCompatible(
        _ storedCode: String,
        with content: QuestionContent,
        language: ProgrammingLanguage
    ) -> Bool {
        guard let meta = LeetCodeMetaData.decode(from: content.metaData) else { return true }

        if meta.isClassDesign, let className = meta.className {
            switch language {
            case .swift:
                let safeName = LeetCodeTemplateBuilder.swiftSafeIdentifier(className, index: 0)
                let boundary = safeName.contains("`") ? "" : "\\b"
                return storedCode.range(
                    of: "\\b(class|struct)\\s+\(boundary)\(NSRegularExpression.escapedPattern(for: safeName))\(boundary)",
                    options: .regularExpression
                ) != nil
            case .python:
                let safeName = LeetCodeTemplateBuilder.pythonSafeIdentifier(className, index: 0)
                return storedCode.range(
                    of: "\\bclass\\s+\(NSRegularExpression.escapedPattern(for: safeName))\\b",
                    options: .regularExpression
                ) != nil
            }
        }

        guard let name = meta.name else { return true }
        switch language {
        case .swift:
            let safeName = LeetCodeTemplateBuilder.swiftSafeIdentifier(name, index: 0)
            let boundary = safeName.contains("`") ? "" : "\\b"
            return storedCode.range(
                of: "\\bfunc\\s+\(boundary)\(NSRegularExpression.escapedPattern(for: safeName))\(boundary)",
                options: .regularExpression
            ) != nil
        case .python:
            let safeName = LeetCodeTemplateBuilder.pythonSafeIdentifier(name, index: 0)
            return storedCode.range(
                of: "\\bdef\\s+\(NSRegularExpression.escapedPattern(for: safeName))\\b",
                options: .regularExpression
            ) != nil
        }
    }
}
