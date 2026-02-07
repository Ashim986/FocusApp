#if os(macOS)
import Foundation

actor ProcessRunState {
    private var currentCancel: (() -> Void)?
    private var wasCancelled = false
    private var didTimeout = false

    func reset() {
        currentCancel = nil
        wasCancelled = false
        didTimeout = false
    }

    func setCancelHandler(_ handler: @escaping () -> Void) {
        currentCancel = handler
    }

    func cancel() {
        wasCancelled = true
        currentCancel?()
    }

    func markTimedOut() {
        didTimeout = true
    }

    func clearCancelHandler() {
        currentCancel = nil
    }

    func flags() -> (wasCancelled: Bool, didTimeout: Bool) {
        (wasCancelled, didTimeout)
    }
}
#endif
