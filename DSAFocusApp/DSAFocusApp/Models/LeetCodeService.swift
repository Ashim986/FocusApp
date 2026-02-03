import Foundation

struct LeetCodeSubmission: Codable {
    let title: String
    let titleSlug: String
    let timestamp: String
    let statusDisplay: String
    let lang: String
}

struct LeetCodeResponse: Codable {
    let count: Int
    let submission: [LeetCodeSubmission]
}

struct LeetCodeUserProfile: Codable {
    let username: String?
    let name: String?
    let ranking: Int?
    let errors: [String]?  // API returns errors array if user not found
}

class LeetCodeService {
    static let shared = LeetCodeService()

    private let apiBaseURL = "https://alfa-leetcode-api.onrender.com"

    private init() {}

    /// Validates if a LeetCode username exists
    func validateUsername(_ username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = "\(apiBaseURL)/\(username)"

        guard let url = URL(string: urlString) else {
            completion(.failure(LeetCodeError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(LeetCodeError.noData))
                return
            }

            // Check if response contains error (user not found)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // If there's an "errors" key or no "username" key, user doesn't exist
                if json["errors"] != nil {
                    completion(.success(false))
                    return
                }
                if let username = json["username"] as? String, !username.isEmpty {
                    completion(.success(true))
                    return
                }
            }

            // Try to decode as profile
            do {
                let profile = try JSONDecoder().decode(LeetCodeUserProfile.self, from: data)
                if profile.errors != nil || profile.username == nil {
                    completion(.success(false))
                } else {
                    completion(.success(true))
                }
            } catch {
                // If decoding fails but we got a response, assume invalid
                completion(.success(false))
            }
        }.resume()
    }

    /// Fetches all accepted submissions for the user
    func fetchSolvedProblems(username: String, completion: @escaping (Result<Set<String>, Error>) -> Void) {
        let urlString = "\(apiBaseURL)/\(username)/acSubmission?limit=500"

        guard let url = URL(string: urlString) else {
            completion(.failure(LeetCodeError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(LeetCodeError.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(LeetCodeResponse.self, from: data)
                // Extract unique titleSlugs (problem identifiers)
                let solvedSlugs = Set(response.submission.map { $0.titleSlug })
                completion(.success(solvedSlugs))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Extracts the titleSlug from a LeetCode problem URL
    /// e.g., "https://leetcode.com/problems/reverse-linked-list/" -> "reverse-linked-list"
    static func extractSlug(from url: String) -> String? {
        // URL format: https://leetcode.com/problems/{slug}/
        let pattern = "leetcode.com/problems/([^/]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
              let range = Range(match.range(at: 1), in: url) else {
            return nil
        }
        return String(url[range])
    }

    /// Syncs LeetCode solved status with the local data store
    func syncWithDataStore(_ dataStore: DataStore, username: String, completion: @escaping (Int, Int) -> Void) {
        fetchSolvedProblems(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let solvedSlugs):
                    var syncedCount = 0
                    var totalMatched = 0

                    // Iterate through all days and problems
                    for day in dsaPlan {
                        for (index, problem) in day.problems.enumerated() {
                            if let slug = LeetCodeService.extractSlug(from: problem.url) {
                                if solvedSlugs.contains(slug) {
                                    totalMatched += 1
                                    // Check if not already marked as solved locally
                                    if !dataStore.isProblemCompleted(day: day.id, problemIndex: index) {
                                        dataStore.data.progress["\(day.id)-\(index)"] = true
                                        syncedCount += 1
                                    }
                                }
                            }
                        }
                    }

                    // Save if any changes were made
                    if syncedCount > 0 {
                        dataStore.save()
                    }

                    completion(syncedCount, totalMatched)

                case .failure(let error):
                    print("LeetCode sync failed: \(error.localizedDescription)")
                    completion(0, 0)
                }
            }
        }
    }
}

enum LeetCodeError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid LeetCode API URL"
        case .noData:
            return "No data received from LeetCode"
        case .decodingError:
            return "Failed to decode LeetCode response"
        }
    }
}
