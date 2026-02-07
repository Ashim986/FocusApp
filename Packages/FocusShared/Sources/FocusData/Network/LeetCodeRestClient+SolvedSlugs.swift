import Foundation

public extension LeetCodeRestClient {
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> {
        var slugs = Set<String>()
        let cappedLimit = min(limit, LeetCodeConstants.manualSubmissionsLimit)

        do {
            let submissions = try await fetchSubmissions(
                username: username,
                path: "acSubmission",
                limit: cappedLimit
            )
            slugs.formUnion(submissions.map { $0.titleSlug })
        } catch {
            // Fall through to broader submission fetch.
        }

        if slugs.isEmpty {
            do {
                let submissions = try await fetchSubmissions(
                    username: username,
                    path: "submission",
                    limit: cappedLimit
                )
                let accepted = submissions.filter { submission in
                    submission.statusDisplay?.caseInsensitiveCompare("accepted") == .orderedSame
                }
                slugs.formUnion(accepted.map { $0.titleSlug })
            } catch {
                // Fall through to GraphQL fallback.
            }
        }

        guard slugs.isEmpty else { return slugs }

        if limit >= LeetCodeConstants.manualSubmissionsLimit {
            if let fallback = try? await fetchSolvedSlugsGraphQLAll(username: username, limit: cappedLimit) {
                return fallback
            }
        }

        return (try? await fetchSolvedSlugsGraphQLRecent(
            username: username,
            limit: min(cappedLimit, 200)
        )) ?? []
    }

    private func fetchSubmissions(
        username: String,
        path: String,
        limit: Int
    ) async throws -> [LeetCodeRestSubmission] {
        let request = try makeRequest(
            path: "\(username)/\(path)",
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        )
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeRestSubmissionListResponse.self, from: data)
        return response.submissions
    }

    private func fetchSolvedSlugsGraphQLRecent(username: String, limit: Int) async throws -> Set<String> {
        let submissions = try await fetchGraphQLAcSubmissions(
            username: username,
            limit: min(limit, 200),
            offset: nil
        )
        return Set(submissions.map { $0.titleSlug })
    }

    private func fetchSolvedSlugsGraphQLAll(username: String, limit: Int) async throws -> Set<String> {
        let targetLimit = min(limit, LeetCodeConstants.manualSubmissionsLimit)
        let pageSize = min(200, targetLimit)
        var offset = 0
        var slugs = Set<String>()
        var seen = Set<String>()

        while offset < targetLimit {
            let submissions = try await fetchGraphQLAcSubmissions(
                username: username,
                limit: pageSize,
                offset: offset
            )
            if submissions.isEmpty { break }

            let beforeCount = slugs.count
            for submission in submissions where seen.insert(submission.titleSlug).inserted {
                slugs.insert(submission.titleSlug)
            }
            if slugs.count == beforeCount { break }
            if submissions.count < pageSize { break }

            offset += pageSize
        }

        if slugs.isEmpty {
            return try await fetchSolvedSlugsGraphQLRecent(username: username, limit: targetLimit)
        }

        return slugs
    }
}
