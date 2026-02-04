import Foundation

enum LeetCodeConstants {
    static let recentSubmissionsLimit = 1000
    static let manualSubmissionsLimit = 5000
    static let restBaseURL = URL(string: "https://alfa-leetcode-api.onrender.com")!
    static let graphQLBaseURL = URL(string: "https://leetcode.com/graphql")!
    static let syncInterval: TimeInterval = 3600
}
