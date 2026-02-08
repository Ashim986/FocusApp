import Foundation

public enum LeetCodeConstants {
    public static let recentSubmissionsLimit = 1000
    public static let manualSubmissionsLimit = 5000

    public static let restBaseURL: URL = {
        guard let url = URL(string: "https://alfa-leetcode-api.onrender.com") else {
            fatalError("Invalid LeetCode REST base URL")
        }
        return url
    }()

    // Backward compatibility alias.
    public static let baseURL: URL = restBaseURL

    public static let graphQLBaseURL: URL = {
        guard let url = URL(string: "https://leetcode.com/graphql") else {
            fatalError("Invalid LeetCode GraphQL base URL")
        }
        return url
    }()

    public static let syncInterval: TimeInterval = 3600
}
