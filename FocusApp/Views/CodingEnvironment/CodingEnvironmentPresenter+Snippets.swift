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
                return storedCode
            }
        }

        if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
           let cached = problemContentCache[slug],
           let snippet = snippetForLanguage(language, from: cached) {
            return snippet
        }

        return ""
    }

    func applySnippetIfNeeded(from content: QuestionContent) {
        guard let problem = selectedProblem else { return }
        let defaultTrimmed = language.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        if let storedCode = loadStoredCode(for: problem, language: language) {
            let trimmed = storedCode.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed != defaultTrimmed {
                return
            }
        }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != defaultTrimmed {
            return
        }
        if let snippet = snippetForLanguage(language, from: content) {
            setCode(snippet)
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
}
