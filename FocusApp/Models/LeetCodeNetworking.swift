import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct NetworkEndpoint {
    let url: URL
    let method: HTTPMethod
    let headers: [String: String]
    let body: Data?
}

protocol RequestBuilding {
    func buildRequest(for endpoint: NetworkEndpoint) -> URLRequest
}

struct DefaultRequestBuilder: RequestBuilding {
    func buildRequest(for endpoint: NetworkEndpoint) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

protocol RequestExecuting {
    func execute(_ request: URLRequest) async throws -> Data
}

final class URLSessionRequestExecutor: RequestExecuting {
    private let session: URLSession

    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    func execute(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
}
