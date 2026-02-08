import Foundation

extension LeetCodeRestClient {
    public func makeRequest(
        path: String,
        queryItems: [URLQueryItem] = []
    ) throws -> URLRequest {
        let fullURL = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else {
            throw LeetCodeError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw LeetCodeError.invalidURL
        }

        let endpoint = NetworkEndpoint(
            url: url,
            method: .get,
            headers: [
                "Accept": "application/json",
                "User-Agent": "FocusApp/1.0"
            ],
            body: nil
        )
        return requestBuilder.buildRequest(for: endpoint)
    }

    public func makeGraphQLRequest(query: String, variables: [String: Any]) throws -> URLRequest {
        let body = try JSONSerialization.data(withJSONObject: [
            "query": query,
            "variables": variables
        ])
        let endpoint = NetworkEndpoint(
            url: graphQLURL,
            method: .post,
            headers: [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "User-Agent": "FocusApp/1.0"
            ],
            body: body
        )
        return requestBuilder.buildRequest(for: endpoint)
    }
}
