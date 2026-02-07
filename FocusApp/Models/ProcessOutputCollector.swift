#if os(macOS)
import Foundation

final class ProcessOutputCollector {
    private let maxOutputLength: Int
    private let lock = NSLock()
    private(set) var outputLimitExceeded = false
    private(set) var errorLimitExceeded = false
    private var outputData = Data()
    private var errorData = Data()

    init(maxOutputLength: Int) {
        self.maxOutputLength = maxOutputLength
    }

    func appendOutput(_ data: Data) {
        append(data, to: &outputData, limitExceeded: &outputLimitExceeded)
    }

    func appendError(_ data: Data) {
        append(data, to: &errorData, limitExceeded: &errorLimitExceeded)
    }

    func outputString(truncate: (String) -> String) -> String {
        truncate(String(data: outputData, encoding: .utf8) ?? "")
    }

    func errorString(truncate: (String) -> String) -> String {
        truncate(String(data: errorData, encoding: .utf8) ?? "")
    }

    private func append(_ data: Data, to buffer: inout Data, limitExceeded: inout Bool) {
        lock.lock()
        defer { lock.unlock() }

        guard !limitExceeded else { return }
        if buffer.count >= maxOutputLength {
            limitExceeded = true
            return
        }
        let remaining = maxOutputLength - buffer.count
        if data.count > remaining {
            buffer.append(data.prefix(remaining))
            limitExceeded = true
        } else {
            buffer.append(data)
        }
    }
}
#endif
