import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpStatus(let status):
            return "Unexpected HTTP status: \(status)"
        }
    }
}

enum LeetCodeError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case invalidPayload
    case graphQLError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid LeetCode API URL"
        case .noData:
            return "No data received from LeetCode"
        case .decodingError:
            return "Failed to decode LeetCode response"
        case .invalidPayload:
            return "Unexpected data from LeetCode"
        case .graphQLError(let message):
            return "LeetCode GraphQL error: \(message)"
        }
    }
}
