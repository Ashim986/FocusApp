import Foundation

@MainActor
func waitForCondition(
    timeout: TimeInterval = 1.0,
    interval: TimeInterval = 0.02,
    condition: @escaping () -> Bool
) async -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
    }
    return condition()
}
