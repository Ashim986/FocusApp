import Foundation

public extension LeetCodeRestClient {
    func fetchProblemContent(slug: String) async throws -> QuestionContent? {
        var restContent: QuestionContent?

        do {
            let request = try makeRequest(
                path: "select",
                queryItems: [
                    URLQueryItem(name: "titleSlug", value: slug)
                ]
            )
            let data = try await executor.execute(request)
            let response = try decoder.decode(LeetCodeRestProblemResponse.self, from: data)
            let snippets = Dictionary(
                uniqueKeysWithValues: response.codeSnippets.map { ($0.langSlug, $0.code) }
            )
            let title: String
            if response.title.isEmpty {
                title = slug.replacingOccurrences(of: "-", with: " ").capitalized
            } else {
                title = response.title
            }

            restContent = QuestionContent(
                title: title,
                content: response.content,
                exampleTestcases: response.exampleTestcases,
                sampleTestCase: response.sampleTestCase,
                difficulty: response.difficulty.isEmpty ? "Unknown" : response.difficulty,
                codeSnippets: snippets,
                metaData: response.metaData,
                questionId: nil
            )
        } catch {
            // Fall through to GraphQL fallback.
        }

        if let restContent {
            let needsFallback = restContent.metaData == nil || restContent.codeSnippets.isEmpty
            if needsFallback, let fallback = try? await fetchProblemContentGraphQL(slug: slug) {
                return mergeProblemContent(primary: restContent, fallback: fallback, slug: slug)
            }
            return restContent
        }

        return try? await fetchProblemContentGraphQL(slug: slug)
    }

    private func mergeProblemContent(
        primary: QuestionContent,
        fallback: QuestionContent,
        slug: String
    ) -> QuestionContent {
        let title = primary.title.isEmpty ? fallback.title : primary.title
        let content = primary.content.isEmpty ? fallback.content : primary.content
        let exampleTestcases = primary.exampleTestcases.isEmpty
            ? fallback.exampleTestcases
            : primary.exampleTestcases
        let sampleTestCase = primary.sampleTestCase.isEmpty
            ? fallback.sampleTestCase
            : primary.sampleTestCase
        let difficulty = primary.difficulty == "Unknown" ? fallback.difficulty : primary.difficulty
        let snippets = primary.codeSnippets.isEmpty ? fallback.codeSnippets : primary.codeSnippets
        let metaData = primary.metaData ?? fallback.metaData
        let normalizedTitle = title.isEmpty ? slug.replacingOccurrences(of: "-", with: " ").capitalized : title

        return QuestionContent(
            title: normalizedTitle,
            content: content,
            exampleTestcases: exampleTestcases,
            sampleTestCase: sampleTestCase,
            difficulty: difficulty.isEmpty ? "Unknown" : difficulty,
            codeSnippets: snippets,
            metaData: metaData,
            questionId: primary.questionId ?? fallback.questionId
        )
    }
}
