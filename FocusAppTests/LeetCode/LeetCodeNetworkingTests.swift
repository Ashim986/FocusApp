@testable import FocusApp
import XCTest

final class LeetCodeNetworkingTests: XCTestCase {
    func testDefaultRequestBuilderSetsFields() {
        let url = URL(string: "https://example.com")!
        let endpoint = NetworkEndpoint(url: url, method: .post, headers: ["X-Test": "1"], body: Data("hi".utf8))

        let request = DefaultRequestBuilder().buildRequest(for: endpoint)

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Test"), "1")
        XCTAssertEqual(request.httpBody, Data("hi".utf8))
    }

    func testURLSessionRequestExecutorHandlesResponses() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)
        let executor = URLSessionRequestExecutor(session: session)
        let url = URL(string: "https://example.com")!

        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("ok".utf8))
        }
        let okData = try await executor.execute(URLRequest(url: url))
        XCTAssertEqual(String(data: okData, encoding: .utf8), "ok")

        URLProtocolStub.handler = { request in
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (response, Data())
        }
        await assertThrowsNetworkError(NetworkError.invalidResponse) {
            _ = try await executor.execute(URLRequest(url: url))
        }

        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        await assertThrowsNetworkError(NetworkError.httpStatus(500)) {
            _ = try await executor.execute(URLRequest(url: url))
        }
    }

    private func assertThrowsNetworkError(_ expected: NetworkError, _ block: @escaping () async throws -> Void) async {
        do {
            try await block()
            XCTFail("Expected error")
        } catch let error as NetworkError {
            switch (error, expected) {
            case (.invalidResponse, .invalidResponse):
                XCTAssertTrue(true)
            case (.httpStatus(let lhs), .httpStatus(let rhs)):
                XCTAssertEqual(lhs, rhs)
            default:
                XCTFail("Unexpected NetworkError")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private final class URLProtocolStub: URLProtocol {
    static var handler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}
