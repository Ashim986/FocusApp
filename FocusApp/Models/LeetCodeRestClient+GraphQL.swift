import Foundation

extension LeetCodeRestClient {
    func fetchGraphQLAcSubmissions(
        username: String,
        limit: Int,
        offset: Int?
    ) async throws -> [LeetCodeGraphQLSubmission] {
        let query: String
        var variables: [String: Any] = [
            "username": username,
            "limit": limit
        ]

        if let offset {
            query = """
            query recentAcSubmissions($username: String!, $limit: Int!, $offset: Int!) {
              recentAcSubmissionList(username: $username, limit: $limit, offset: $offset) {
                titleSlug
              }
            }
            """
            variables["offset"] = offset
        } else {
            query = """
            query recentAcSubmissions($username: String!, $limit: Int!) {
              recentAcSubmissionList(username: $username, limit: $limit) {
                titleSlug
              }
            }
            """
        }

        let request = try makeGraphQLRequest(query: query, variables: variables)
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeGraphQLResponse<LeetCodeRecentAcSubmissionsData>.self, from: data)
        if let errors = response.errors, !errors.isEmpty {
            let message = errors.map { $0.message }.joined(separator: "; ")
            throw LeetCodeError.graphQLError(message)
        }
        return response.data?.recentAcSubmissionList ?? []
    }

    func fetchProblemContentGraphQL(slug: String) async throws -> QuestionContent? {
        let query = """
        query questionData($titleSlug: String!) {
          question(titleSlug: $titleSlug) {
            questionId
            title
            content
            exampleTestcases
            sampleTestCase
            difficulty
            codeSnippets {
              langSlug
              code
            }
            metaData
          }
        }
        """
        let request = try makeGraphQLRequest(query: query, variables: ["titleSlug": slug])
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeGraphQLResponse<LeetCodeGraphQLQuestionData>.self, from: data)
        if let errors = response.errors, !errors.isEmpty {
            let message = errors.map { $0.message }.joined(separator: "; ")
            throw LeetCodeError.graphQLError(message)
        }
        guard let question = response.data?.question else { return nil }

        let snippets = Dictionary(uniqueKeysWithValues: question.codeSnippets.map { ($0.langSlug, $0.code) })
        let title = question.title.isEmpty ? slug.replacingOccurrences(of: "-", with: " ").capitalized : question.title

        return QuestionContent(
            title: title,
            content: question.content,
            exampleTestcases: question.exampleTestcases,
            sampleTestCase: question.sampleTestCase,
            difficulty: question.difficulty.isEmpty ? "Unknown" : question.difficulty,
            codeSnippets: snippets,
            metaData: question.metaData,
            questionId: question.questionId
        )
    }
}
