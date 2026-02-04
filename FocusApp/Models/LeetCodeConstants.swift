import Foundation

enum LeetCodeConstants {
    static let recentSubmissionsLimit = 1000
    static let manualSubmissionsLimit = 5000
    static let restBaseURL: URL = {
        guard let url = URL(string: "https://alfa-leetcode-api.onrender.com") else {
            fatalError("Invalid LeetCode REST base URL")
        }
        return url
    }()
    static let graphQLBaseURL: URL = {
        guard let url = URL(string: "https://leetcode.com/graphql") else {
            fatalError("Invalid LeetCode GraphQL base URL")
        }
        return url
    }()
    static let syncInterval: TimeInterval = 3600
}
