import Foundation

enum DataJourneyEventKind: String {
    case input
    case output
    case step
}

struct DataJourneyEvent: Identifiable {
    let id = UUID()
    let kind: DataJourneyEventKind
    let line: Int?
    let label: String?
    let values: [String: TraceValue]

    static func from(json: Any) -> DataJourneyEvent? {
        guard let dict = json as? [String: Any] else { return nil }
        guard let kindString = dict["kind"] as? String,
              let kind = DataJourneyEventKind(rawValue: kindString) else { return nil }

        let line: Int?
        if let lineValue = dict["line"] as? Int {
            line = lineValue
        } else if let lineNumber = dict["line"] as? NSNumber {
            line = lineNumber.intValue
        } else {
            line = nil
        }

        let label = dict["label"] as? String
        let valuesDict = dict["values"] as? [String: Any] ?? [:]
        let values = valuesDict.mapValues { TraceValue.from(json: $0) }

        return DataJourneyEvent(kind: kind, line: line, label: label, values: values)
    }
}

indirect enum TraceValue: Equatable {
    case null
    case bool(Bool)
    case number(Double, isInt: Bool)
    case string(String)
    case array([TraceValue])
    case object([String: TraceValue])
    case list([TraceValue], cycleIndex: Int?, isTruncated: Bool)
    case typed(String, TraceValue)

    static func from(json: Any) -> TraceValue {
        if json is NSNull { return .null }
        if let number = json as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return .bool(number.boolValue)
            }
            let doubleValue = number.doubleValue
            let intValue = number.intValue
            let isInt = Double(intValue) == doubleValue
            return .number(doubleValue, isInt: isInt)
        }
        if let boolValue = json as? Bool { return .bool(boolValue) }
        if let stringValue = json as? String { return .string(stringValue) }
        if let arrayValue = json as? [Any] {
            return .array(arrayValue.map { TraceValue.from(json: $0) })
        }
        if let dictValue = json as? [String: Any] {
            if let type = dictValue["__type"] as? String, let value = dictValue["value"] {
                if type.lowercased() == "list" {
                    let items = TraceValue.from(json: value).arrayValues
                    let cycleIndex = TraceValue.intValue(from: dictValue["cycleIndex"])
                    let isTruncated = (dictValue["truncated"] as? Bool) ?? false
                    return .list(items, cycleIndex: cycleIndex, isTruncated: isTruncated)
                }
                return .typed(type, TraceValue.from(json: value))
            }
            return .object(dictValue.mapValues { TraceValue.from(json: $0) })
        }
        return .string(String(describing: json))
    }
}

extension TraceValue {
    fileprivate var arrayValues: [TraceValue] {
        if case .array(let items) = self { return items }
        return []
    }

    fileprivate static func intValue(from value: Any?) -> Int? {
        if let intValue = value as? Int { return intValue }
        if let number = value as? NSNumber { return number.intValue }
        if let string = value as? String, let intValue = Int(string) { return intValue }
        return nil
    }
}
