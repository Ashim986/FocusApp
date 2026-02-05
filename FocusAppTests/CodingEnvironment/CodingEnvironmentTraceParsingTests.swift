@testable import FocusApp
import XCTest

final class CodingEnvironmentTraceParsingTests: XCTestCase {
    @MainActor
    func testParseTraceOutputExtractsEventsAndCleansOutput() {
        let presenter = makeCodingPresenter()
        let traceLine = "__focus_trace__{\"kind\":\"input\",\"values\":{\"nums\":[1,2],\"flag\":true}}"
        let output = [traceLine, "result"].joined(separator: "\n")

        let parsed = presenter.parseTraceOutput(output)

        XCTAssertEqual(parsed.events.count, 1)
        XCTAssertEqual(parsed.events.first?.kind, .input)
        XCTAssertEqual(parsed.cleanOutput.trimmingCharacters(in: .whitespacesAndNewlines), "result")
        XCTAssertEqual(parsed.isTruncated, false)

        guard let event = parsed.events.first else {
            XCTFail("Missing event")
            return
        }
        if case .array(let items) = event.values["nums"] {
            XCTAssertEqual(items.count, 2)
        } else {
            XCTFail("Expected nums to be an array")
        }
        XCTAssertEqual(event.values["flag"], .bool(true))
    }

    @MainActor
    func testCapTraceEventsLimitsStepCount() {
        let presenter = makeCodingPresenter()
        var events: [DataJourneyEvent] = []
        events.append(DataJourneyEvent(kind: .input, line: nil, label: nil, values: ["input": .null]))
        for index in 0..<45 {
            events.append(DataJourneyEvent(kind: .step, line: index, label: "step", values: [:]))
        }
        events.append(DataJourneyEvent(kind: .output, line: nil, label: nil, values: ["result": .number(1, isInt: true)]))

        let capped = presenter.capTraceEvents(events)

        XCTAssertTrue(capped.isTruncated)
        XCTAssertEqual(capped.events.filter { $0.kind == .step }.count, 40)
        XCTAssertEqual(capped.events.first?.kind, .input)
        XCTAssertEqual(capped.events.last?.kind, .output)
    }
}
