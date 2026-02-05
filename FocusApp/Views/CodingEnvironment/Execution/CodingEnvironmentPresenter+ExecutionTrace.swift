import Foundation

extension CodingEnvironmentPresenter {
    struct TraceParseResult {
        let events: [DataJourneyEvent]
        let cleanOutput: String
        let isTruncated: Bool
    }

    func parseTraceOutput(_ output: String) -> TraceParseResult {
        let prefix = "__focus_trace__"
        guard output.contains(prefix) else {
            return TraceParseResult(events: [], cleanOutput: output, isTruncated: false)
        }

        let lines = output.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        var cleanLines: [String] = []
        var events: [DataJourneyEvent] = []
        var sawTraceTruncation = false

        for rawLine in lines {
            let line = String(rawLine)
            if line.hasPrefix(prefix) {
                let jsonString = String(line.dropFirst(prefix.count))
                if let data = jsonString.data(using: String.Encoding.utf8),
                   var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if var values = json["values"] as? [String: Any] {
                        if let truncated = values["__trace_truncated"] as? Bool, truncated {
                            sawTraceTruncation = true
                        }
                        values.removeValue(forKey: "__trace_truncated")
                        json["values"] = values
                    }
                    if let event = DataJourneyEvent.from(json: json) {
                        events.append(event)
                    }
                }
            } else {
                cleanLines.append(line)
            }
        }

        let capped = capTraceEvents(events)
        let cleanOutput = cleanLines.joined(separator: "\n")
        let isTruncated = capped.isTruncated || sawTraceTruncation
        return TraceParseResult(events: capped.events, cleanOutput: cleanOutput, isTruncated: isTruncated)
    }

    func capTraceEvents(_ events: [DataJourneyEvent]) -> (events: [DataJourneyEvent], isTruncated: Bool) {
        let maxSteps = 40
        var stepCount = 0
        var capped: [DataJourneyEvent] = []
        var isTruncated = false

        for event in events {
            if event.kind == .step {
                guard stepCount < maxSteps else {
                    isTruncated = true
                    continue
                }
                stepCount += 1
            }
            capped.append(event)
        }

        return (capped, isTruncated)
    }
}
