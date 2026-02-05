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

struct TraceListNode: Equatable {
    let id: String
    let value: TraceValue
}

struct TraceList: Equatable {
    let nodes: [TraceListNode]
    let cycleIndex: Int?
    let isTruncated: Bool
}

struct TraceTreeNode: Equatable {
    let id: String
    let value: TraceValue
    let left: String?
    let right: String?
}

struct TraceTree: Equatable {
    let nodes: [TraceTreeNode]
    let rootId: String?
    let isTruncated: Bool
}

extension TraceTree {
    static func fromLevelOrder(_ items: [TraceValue]) -> TraceTree {
        guard !items.isEmpty else {
            return TraceTree(nodes: [], rootId: nil, isTruncated: false)
        }
        var nodes: [TraceTreeNode] = []
        for (index, value) in items.enumerated() {
            guard value != .null else { continue }
            let id = "i\(index)"
            let leftIndex = 2 * index + 1
            let rightIndex = 2 * index + 2
            let leftId = leftIndex < items.count && items[leftIndex] != .null
                ? "i\(leftIndex)"
                : nil
            let rightId = rightIndex < items.count && items[rightIndex] != .null
                ? "i\(rightIndex)"
                : nil
            nodes.append(TraceTreeNode(id: id, value: value, left: leftId, right: rightId))
        }
        let rootId = items.first == .null ? nil : "i0"
        return TraceTree(nodes: nodes, rootId: rootId, isTruncated: false)
    }
}

indirect enum TraceValue: Equatable {
    case null
    case bool(Bool)
    case number(Double, isInt: Bool)
    case string(String)
    case array([TraceValue])
    case object([String: TraceValue])
    case list(TraceList)
    case listPointer(String)
    case tree(TraceTree)
    case treePointer(String)
    case typed(String, TraceValue)

    static func from(json: Any) -> TraceValue {
        if let primitive = TraceValue.primitive(from: json) {
            return primitive
        }
        if let arrayValue = json as? [Any] {
            return .array(arrayValue.map { TraceValue.from(json: $0) })
        }
        if let dictValue = json as? [String: Any] {
            return TraceValue.typedValue(from: dictValue)
                ?? .object(dictValue.mapValues { TraceValue.from(json: $0) })
        }
        return .string(String(describing: json))
    }
}

extension TraceValue {
    fileprivate static func primitive(from json: Any) -> TraceValue? {
        if json is NSNull { return .null }
        if let number = json as? NSNumber {
            let objCType = String(cString: number.objCType)
            if objCType == "c" || objCType == "B" {
                return .bool(number.boolValue)
            }
            let doubleValue = number.doubleValue
            let intValue = number.intValue
            let isInt = Double(intValue) == doubleValue
            return .number(doubleValue, isInt: isInt)
        }
        if let boolValue = json as? Bool { return .bool(boolValue) }
        if let stringValue = json as? String { return .string(stringValue) }
        return nil
    }

    fileprivate static func typedValue(from dictValue: [String: Any]) -> TraceValue? {
        guard let type = dictValue["__type"] as? String else { return nil }
        switch type.lowercased() {
        case "list":
            let nodes = TraceValue.listNodes(from: dictValue["nodes"])
            let cycleIndex = TraceValue.intValue(from: dictValue["cycleIndex"])
            let isTruncated = (dictValue["truncated"] as? Bool) ?? false
            return .list(TraceList(nodes: nodes, cycleIndex: cycleIndex, isTruncated: isTruncated))
        case "listpointer":
            if let id = dictValue["id"] as? String {
                return .listPointer(id)
            }
        case "tree":
            let nodes = TraceValue.treeNodes(from: dictValue["nodes"])
            let rootId = dictValue["rootId"] as? String
            let isTruncated = (dictValue["truncated"] as? Bool) ?? false
            return .tree(TraceTree(nodes: nodes, rootId: rootId, isTruncated: isTruncated))
        case "treepointer":
            if let id = dictValue["id"] as? String {
                return .treePointer(id)
            }
        default:
            if let value = dictValue["value"] {
                return .typed(type, TraceValue.from(json: value))
            }
        }
        return nil
    }

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

    fileprivate static func listNodes(from value: Any?) -> [TraceListNode] {
        guard let rawNodes = value as? [Any] else { return [] }
        return rawNodes.compactMap { entry in
            guard let dict = entry as? [String: Any],
                  let id = dict["id"] as? String else { return nil }
            let value = dict["value"].map { TraceValue.from(json: $0) } ?? .null
            return TraceListNode(id: id, value: value)
        }
    }

    fileprivate static func treeNodes(from value: Any?) -> [TraceTreeNode] {
        guard let rawNodes = value as? [Any] else { return [] }
        return rawNodes.compactMap { entry in
            guard let dict = entry as? [String: Any],
                  let id = dict["id"] as? String else { return nil }
            let value = dict["value"].map { TraceValue.from(json: $0) } ?? .null
            let left = dict["left"] as? String
            let right = dict["right"] as? String
            return TraceTreeNode(id: id, value: value, left: left, right: right)
        }
    }
}
