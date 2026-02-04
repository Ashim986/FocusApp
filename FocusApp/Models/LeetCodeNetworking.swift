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
    private let logger: DebugLogRecording?

    init(
        session: URLSession = URLSession(configuration: .default),
        logger: DebugLogRecording? = nil
    ) {
        self.session = session
        self.logger = logger
    }

    func execute(_ request: URLRequest) async throws -> Data {
        let startTime = Date()
        let method = request.httpMethod ?? HTTPMethod.get.rawValue
        let urlString = request.url?.absoluteString ?? "unknown"

        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .network,
                title: "Request",
                message: "\(method) \(urlString)",
                metadata: [
                    "method": method,
                    "url": urlString
                ]
            )
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                logger?.recordAsync(
                    DebugLogEntry(
                        level: .error,
                        category: .network,
                        title: "Invalid response",
                        message: "\(method) \(urlString)",
                        metadata: [
                            "method": method,
                            "url": urlString
                        ]
                    )
                )
                throw NetworkError.invalidResponse
            }
            let duration = Int(Date().timeIntervalSince(startTime) * 1000)
            logger?.recordAsync(
                DebugLogEntry(
                    level: (200..<300).contains(httpResponse.statusCode) ? .info : .error,
                    category: .network,
                    title: "Response",
                    message: "\(httpResponse.statusCode) \(method) \(urlString)",
                    metadata: [
                        "status": "\(httpResponse.statusCode)",
                        "duration_ms": "\(duration)",
                        "bytes": "\(data.count)"
                    ]
                )
            )
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpStatus(httpResponse.statusCode)
            }
            return data
        } catch {
            let duration = Int(Date().timeIntervalSince(startTime) * 1000)
            logger?.recordAsync(
                DebugLogEntry(
                    level: .error,
                    category: .network,
                    title: "Request failed",
                    message: "\(method) \(urlString)",
                    metadata: [
                        "duration_ms": "\(duration)",
                        "error": error.localizedDescription
                    ]
                )
            )
            throw error
        }
    }
}

enum DebugLogLevel: String, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
}

enum DebugLogCategory: String, CaseIterable {
    case network = "Network"
    case sync = "Sync"
    case execution = "Execution"
    case app = "App"
}

struct DebugLogEntry: Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let level: DebugLogLevel
    let category: DebugLogCategory
    let title: String
    let message: String
    let metadata: [String: String]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        level: DebugLogLevel,
        category: DebugLogCategory,
        title: String,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.title = title
        self.message = message
        self.metadata = metadata
    }
}

protocol DebugLogRecording: AnyObject {
    func recordAsync(_ entry: DebugLogEntry)
}

@MainActor
final class DebugLogStore: ObservableObject, DebugLogRecording {
    @Published private(set) var entries: [DebugLogEntry] = []
    private let maxEntries: Int

    init(maxEntries: Int = 500) {
        self.maxEntries = maxEntries
    }

    func record(_ entry: DebugLogEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    nonisolated func recordAsync(_ entry: DebugLogEntry) {
        Task { @MainActor in
            self.record(entry)
        }
    }

    func clear() {
        entries.removeAll()
    }
}
