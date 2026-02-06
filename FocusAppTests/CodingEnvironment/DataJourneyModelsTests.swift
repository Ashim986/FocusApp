@testable import FocusApp
import XCTest

final class DataJourneyModelsTests: XCTestCase {
    func testTraceValueFromJSONHandlesNullAndNumbers() {
        XCTAssertEqual(TraceValue.from(json: NSNull()), .null)

        let number = NSNumber(value: 7)
        switch TraceValue.from(json: number) {
        case .number(let value, let isInt):
            XCTAssertEqual(value, 7)
            XCTAssertTrue(isInt)
        default:
            XCTFail("Expected number")
        }
    }

    func testTraceValueFromJSONHandlesBool() {
        let boolValue = NSNumber(value: true)
        XCTAssertEqual(TraceValue.from(json: boolValue), .bool(true))
    }

    func testTraceValueFromJSONHandlesTypedValues() {
        let json: [String: Any] = ["__type": "custom", "value": [1, 2]]
        let value = TraceValue.from(json: json)

        guard case .typed(let type, let inner) = value else {
            XCTFail("Expected typed value")
            return
        }
        XCTAssertEqual(type, "custom")
        if case .array(let items) = inner {
            XCTAssertEqual(items.count, 2)
        } else {
            XCTFail("Expected array inner value")
        }
    }

    func testDataJourneyEventFromJSONParsesLineAndLabel() {
        let json: [String: Any] = [
            "kind": "step",
            "line": NSNumber(value: 12),
            "label": "after",
            "values": ["x": 1]
        ]

        let event = DataJourneyEvent.from(json: json)

        XCTAssertEqual(event?.kind, .step)
        XCTAssertEqual(event?.line, 12)
        XCTAssertEqual(event?.label, "after")
    }
}
