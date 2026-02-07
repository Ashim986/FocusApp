import Foundation

public extension LeetCodeRestClient {
    func validateUsername(_ username: String) async throws -> Bool {
        let request = try makeRequest(path: username)
        let data = try await executor.execute(request)
        let response = try decoder.decode(LeetCodeUserProfileResponse.self, from: data)
        guard let name = response.username?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return false
        }
        return true
    }
}
