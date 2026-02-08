import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpStatus(let status):
            return "Unexpected HTTP status: \(status)"
        }
    }
}

public enum LeetCodeError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case invalidPayload
    case graphQLError(String)

    public var errorDescription: String? {
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

public enum LeetCodeSubmissionError: Error, LocalizedError {
    case missingAuth
    case invalidURL
    case invalidResponse
    case submissionFailed(String)
    case timeout

    public var errorDescription: String? {
        switch self {
        case .missingAuth:
            return "LeetCode login required."
        case .invalidURL:
            return "Invalid LeetCode submission URL."
        case .invalidResponse:
            return "Invalid response from LeetCode."
        case .submissionFailed(let message):
            return message
        case .timeout:
            return "LeetCode submission timed out."
        }
    }
}
