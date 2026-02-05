@testable import FocusApp
import XCTest

final class ExecutionConfigTests: XCTestCase {
    func testDefaultConfigValues() {
        let config = ExecutionConfig.default

        XCTAssertEqual(config.timeout, 10)
        XCTAssertEqual(config.tempDirectory, FileManager.default.temporaryDirectory)
    }

    func testCustomConfigValues() {
        let customDir = URL(fileURLWithPath: "/custom/temp")
        let config = ExecutionConfig(timeout: 30, tempDirectory: customDir)

        XCTAssertEqual(config.timeout, 30)
        XCTAssertEqual(config.tempDirectory, customDir)
    }
}
