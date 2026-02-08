import Combine
import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public struct NetworkEndpoint {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?

    public init(url: URL, method: HTTPMethod, headers: [String: String], body: Data?) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }
}

public protocol RequestBuilding {
    func buildRequest(for endpoint: NetworkEndpoint) -> URLRequest
}

public struct DefaultRequestBuilder: RequestBuilding {
    public init() {}

    public func buildRequest(for endpoint: NetworkEndpoint) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

public protocol RequestExecuting {
    func execute(_ request: URLRequest) async throws -> Data
}

public final class URLSessionRequestExecutor: RequestExecuting {
    private let session: URLSession
    private let logger: DebugLogRecording?
    private let maxBodyLogLength = 4000

    public init(
        session: URLSession = URLSession(configuration: .default),
        logger: DebugLogRecording? = nil
    ) {
        self.session = session
        self.logger = logger
    }

    public func execute(_ request: URLRequest) async throws -> Data {
        let startTime = Date()
        let method = request.httpMethod ?? HTTPMethod.get.rawValue
        let urlString = request.url?.absoluteString ?? "unknown"
        let requestDetails = formatRequestDetails(request, method: method, url: urlString)
        let curlCommand = buildCurlCommand(request, method: method, url: urlString)
        let context = RequestLogContext(
            method: method,
            urlString: urlString,
            requestDetails: requestDetails,
            curlCommand: curlCommand
        )

        logRequest(context)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                logInvalidResponse(context)
                throw NetworkError.invalidResponse
            }
            let duration = Int(Date().timeIntervalSince(startTime) * 1000)
            let responseDetails = formatResponseDetails(
                response: httpResponse,
                data: data,
                duration: duration,
                url: urlString
            )
            logResponse(
                context,
                status: httpResponse.statusCode,
                duration: duration,
                bytes: data.count,
                responseDetails: responseDetails
            )
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpStatus(httpResponse.statusCode)
            }
            return data
        } catch {
            let duration = Int(Date().timeIntervalSince(startTime) * 1000)
            logFailure(context, duration: duration, error: error.localizedDescription)
            throw error
        }
    }

    private struct RequestLogContext {
        let method: String
        let urlString: String
        let requestDetails: String?
        let curlCommand: String?
    }

    private func logRequest(_ context: RequestLogContext) {
        logger?.recordAsync(
            DebugLogEntry(
                level: .info,
                category: .network,
                title: "Request",
                message: "\(context.method) \(context.urlString)",
                metadata: buildRequestMetadata(
                    method: context.method,
                    url: context.urlString,
                    details: context.requestDetails,
                    curl: context.curlCommand
                )
            )
        )
    }

    private func logInvalidResponse(_ context: RequestLogContext) {
        logger?.recordAsync(
            DebugLogEntry(
                level: .error,
                category: .network,
                title: "Invalid response",
                message: "\(context.method) \(context.urlString)",
                metadata: buildRequestMetadata(
                    method: context.method,
                    url: context.urlString,
                    details: context.requestDetails,
                    curl: context.curlCommand
                )
            )
        )
    }

    private func logResponse(
        _ context: RequestLogContext,
        status: Int,
        duration: Int,
        bytes: Int,
        responseDetails: String?
    ) {
        logger?.recordAsync(
            DebugLogEntry(
                level: (200..<300).contains(status) ? .info : .error,
                category: .network,
                title: "Response",
                message: "\(status) \(context.method) \(context.urlString)",
                metadata: buildResponseMetadata(
                    status: status,
                    duration: duration,
                    bytes: bytes,
                    details: responseDetails,
                    requestDetails: context.requestDetails,
                    curl: context.curlCommand
                )
            )
        )
    }

    private func logFailure(_ context: RequestLogContext, duration: Int, error: String) {
        logger?.recordAsync(
            DebugLogEntry(
                level: .error,
                category: .network,
                title: "Request failed",
                message: "\(context.method) \(context.urlString)",
                metadata: buildFailureMetadata(
                    duration: duration,
                    error: error,
                    requestDetails: context.requestDetails,
                    curl: context.curlCommand
                )
            )
        )
    }

    private func buildRequestMetadata(
        method: String,
        url: String,
        details: String?,
        curl: String?
    ) -> [String: String] {
        var metadata: [String: String] = [
            "method": method,
            "url": url
        ]
        if let details {
            metadata["request"] = details
        }
        if let curl {
            metadata["curl"] = curl
        }
        return metadata
    }

    private func buildResponseMetadata(
        status: Int,
        duration: Int,
        bytes: Int,
        details: String?,
        requestDetails: String?,
        curl: String?
    ) -> [String: String] {
        var metadata: [String: String] = [
            "status": "\(status)",
            "duration_ms": "\(duration)",
            "bytes": "\(bytes)"
        ]
        if let details {
            metadata["response"] = details
        }
        if let requestDetails {
            metadata["request"] = requestDetails
        }
        if let curl {
            metadata["curl"] = curl
        }
        return metadata
    }

    private func buildFailureMetadata(
        duration: Int,
        error: String,
        requestDetails: String?,
        curl: String?
    ) -> [String: String] {
        var metadata: [String: String] = [
            "duration_ms": "\(duration)",
            "error": error
        ]
        if let requestDetails {
            metadata["request"] = requestDetails
        }
        if let curl {
            metadata["curl"] = curl
        }
        return metadata
    }

    private func formatRequestDetails(_ request: URLRequest, method: String, url: String) -> String? {
        var payload: [String: Any] = [
            "method": method,
            "url": url
        ]
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            payload["headers"] = sanitizedHeaders(headers)
        }
        if let bodyValue = bodyPayload(from: request.httpBody) {
            payload["body"] = bodyValue
        }
        return prettyPrintedJSONString(from: payload)
    }

    private func formatResponseDetails(
        response: HTTPURLResponse,
        data: Data,
        duration: Int,
        url: String
    ) -> String? {
        var payload: [String: Any] = [
            "status": response.statusCode,
            "duration_ms": duration,
            "bytes": data.count,
            "url": url
        ]
        let headers = responseHeaderFields(response)
        if !headers.isEmpty {
            payload["headers"] = headers
        }
        if let bodyValue = bodyPayload(from: data) {
            payload["body"] = bodyValue
        }
        return prettyPrintedJSONString(from: payload)
    }

    private func sanitizedHeaders(_ headers: [String: String]) -> [String: String] {
        let sensitive = ["authorization", "cookie", "set-cookie", "x-api-key"]
        return headers.reduce(into: [String: String]()) { result, entry in
            let key = entry.key
            let value = entry.value
            if sensitive.contains(key.lowercased()) {
                result[key] = "<redacted>"
            } else {
                result[key] = value
            }
        }
    }

    private func responseHeaderFields(_ response: HTTPURLResponse) -> [String: String] {
        var headers: [String: String] = [:]
        for (key, value) in response.allHeaderFields {
            let keyString = String(describing: key)
            headers[keyString] = String(describing: value)
        }
        return sanitizedHeaders(headers)
    }

    private func bodyPayload(from data: Data?) -> Any? {
        guard let data, !data.isEmpty else { return nil }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
            return jsonObject
        }
        if let text = String(data: data, encoding: .utf8) {
            return trimmed(text)
        }
        return "<\(data.count) bytes>"
    }

    private func prettyPrintedJSONString(from payload: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(payload) else { return nil }
        guard let data = try? JSONSerialization.data(
            withJSONObject: payload,
            options: [.prettyPrinted, .sortedKeys]
        ) else {
            return nil
        }
        guard let text = String(data: data, encoding: .utf8) else { return nil }
        return trimmed(text)
    }

    private func buildCurlCommand(_ request: URLRequest, method: String, url: String) -> String? {
        var components: [String] = []
        components.append("curl -X \(method) '\(url)'")

        if let headers = request.allHTTPHeaderFields {
            let sanitized = sanitizedHeaders(headers)
            for (key, value) in sanitized.sorted(by: { $0.key < $1.key }) {
                components.append("  -H '\(escapeSingleQuotes(key)): \(escapeSingleQuotes(value))'")
            }
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            let trimmedBody = trimmed(bodyString)
            components.append("  --data-raw '\(escapeSingleQuotes(trimmedBody))'")
        }

        return components.joined(separator: " \\\n")
    }

    private func escapeSingleQuotes(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "'\"'\"'")
    }

    private func trimmed(_ value: String) -> String {
        guard value.count > maxBodyLogLength else { return value }
        let prefix = value.prefix(maxBodyLogLength)
        return String(prefix) + "\n... (truncated)"
    }
}

public enum DebugLogLevel: String, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
}

public enum DebugLogCategory: String, CaseIterable {
    case network = "Network"
    case sync = "Sync"
    case execution = "Execution"
    case app = "App"
}

public struct DebugLogEntry: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let level: DebugLogLevel
    public let category: DebugLogCategory
    public let title: String
    public let message: String
    public let metadata: [String: String]

    public init(
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

public protocol DebugLogRecording: AnyObject {
    func recordAsync(_ entry: DebugLogEntry)
}

@MainActor
public final class DebugLogStore: ObservableObject, DebugLogRecording {
    @Published public private(set) var entries: [DebugLogEntry] = []
    private let maxEntries: Int

    public init(maxEntries: Int = 500) {
        self.maxEntries = maxEntries
    }

    public func record(_ entry: DebugLogEntry) {
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    nonisolated public func recordAsync(_ entry: DebugLogEntry) {
        Task { @MainActor in
            self.record(entry)
        }
    }

    public func clear() {
        entries.removeAll()
    }
}
