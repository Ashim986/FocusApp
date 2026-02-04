import Foundation

enum LeetCodeSlugExtractor {
    static func extractSlug(from url: String) -> String? {
        let pattern = "leetcode.com/problems/([^/]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
              let range = Range(match.range(at: 1), in: url) else {
            return nil
        }
        return String(url[range])
    }
}
