import Foundation

indirect enum LeetCodeValueType: Equatable {
    case int
    case double
    case bool
    case string
    case character
    case void
    case list(LeetCodeValueType)
    case dictionary(LeetCodeValueType, LeetCodeValueType)
    case listNode
    case treeNode
    case unknown(String)

    init(raw: String) {
        let normalized = Self.normalizeTypeString(raw)
        let trimmed = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        if let container = Self.parseContainerType(trimmed: trimmed, lower: lower) {
            self = container
            return
        }

        self = Self.primitiveTypeMap[lower] ?? .unknown(trimmed)
    }

    private static let primitiveTypeMap: [String: LeetCodeValueType] = [
        "int": .int,
        "integer": .int,
        "long": .int,
        "short": .int,
        "byte": .int,

        "double": .double,
        "float": .double,
        "decimal": .double,

        "bool": .bool,
        "boolean": .bool,

        "string": .string,
        "str": .string,

        "char": .character,
        "character": .character,

        "void": .void,

        "listnode": .listNode,
        "treenode": .treeNode
    ]

    private static func parseContainerType(trimmed: String, lower: String) -> LeetCodeValueType? {
        if lower.hasSuffix("[]") {
            let innerRaw = String(trimmed.dropLast(2))
            return .list(LeetCodeValueType(raw: innerRaw))
        }

        if lower.hasPrefix("list<"), lower.hasSuffix(">") {
            let innerRaw = genericInner(trimmed: trimmed, prefixCount: 5)
            return .list(LeetCodeValueType(raw: innerRaw))
        }

        if lower.hasPrefix("map<"), lower.hasSuffix(">") {
            let innerRaw = genericInner(trimmed: trimmed, prefixCount: 4)
            let parts = splitGenericArguments(innerRaw)
            guard parts.count == 2 else { return nil }
            return .dictionary(LeetCodeValueType(raw: parts[0]), LeetCodeValueType(raw: parts[1]))
        }

        return nil
    }

    private static func genericInner(trimmed: String, prefixCount: Int) -> String {
        let start = trimmed.index(trimmed.startIndex, offsetBy: prefixCount)
        let end = trimmed.index(before: trimmed.endIndex)
        return String(trimmed[start..<end])
    }

    private static func normalizeTypeString(_ raw: String) -> String {
        var value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.replacingOccurrences(of: " ", with: "")

        if value.hasSuffix("?") {
            value = String(value.dropLast())
        }

        if value.hasPrefix("Optional<"), value.hasSuffix(">") {
            let inner = String(value.dropFirst("Optional<".count).dropLast())
            return normalizeTypeString(inner)
        }

        if value.hasPrefix("Array<"), value.hasSuffix(">") {
            let inner = String(value.dropFirst("Array<".count).dropLast())
            return "list<\(normalizeTypeString(inner))>"
        }

        if value.hasPrefix("Dictionary<"), value.hasSuffix(">") {
            let inner = String(value.dropFirst("Dictionary<".count).dropLast())
            let parts = splitGenericArguments(inner)
            if parts.count == 2 {
                return "map<\(normalizeTypeString(parts[0])),\(normalizeTypeString(parts[1]))>"
            }
        }

        if value.hasPrefix("["), value.hasSuffix("]") {
            let inner = String(value.dropFirst().dropLast())
            if inner.contains(":") {
                let parts = splitDictionaryPair(inner)
                if parts.count == 2 {
                    return "map<\(normalizeTypeString(parts[0])),\(normalizeTypeString(parts[1]))>"
                }
            }
            return "list<\(normalizeTypeString(inner))>"
        }

        return value
    }
    private static func splitGenericArguments(_ value: String) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0
        for char in value {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == "," && depth == 0 {
                results.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
                continue
            }
            current.append(char)
        }
        if !current.isEmpty {
            results.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return results
    }

    private static func splitDictionaryPair(_ value: String) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0
        for char in value {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == ":" && depth == 0 {
                results.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
                continue
            }
            current.append(char)
        }
        if !current.isEmpty {
            results.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return results
    }

    var needsListNode: Bool {
        switch self {
        case .listNode:
            return true
        case .list(let inner):
            return inner.needsListNode
        case .dictionary(let key, let value):
            return key.needsListNode || value.needsListNode
        default:
            return false
        }
    }

    var needsTreeNode: Bool {
        switch self {
        case .treeNode:
            return true
        case .list(let inner):
            return inner.needsTreeNode
        case .dictionary(let key, let value):
            return key.needsTreeNode || value.needsTreeNode
        default:
            return false
        }
    }

    var swiftType: String {
        switch self {
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .string:
            return "String"
        case .character:
            return "Character"
        case .void:
            return "Void"
        case .list(let inner):
            return "[\(inner.swiftType)]"
        case .dictionary(let key, let value):
            return "[\(key.swiftDictionaryKeyType): \(value.swiftType)]"
        case .listNode:
            return "ListNode?"
        case .treeNode:
            return "TreeNode?"
        case .unknown:
            return "Any"
        }
    }

    private var swiftDictionaryKeyType: String {
        switch self {
        case .string:
            return "String"
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .character:
            return "Character"
        default:
            return "String"
        }
    }

    var pythonType: String {
        switch self {
        case .int:
            return "int"
        case .double:
            return "float"
        case .bool:
            return "bool"
        case .string, .character:
            return "str"
        case .void:
            return "None"
        case .list(let inner):
            return "List[\(inner.pythonType)]"
        case .dictionary(let key, let value):
            return "Dict[\(key.pythonType), \(value.pythonType)]"
        case .listNode:
            return "Optional[ListNode]"
        case .treeNode:
            return "Optional[TreeNode]"
        case .unknown:
            return "Any"
        }
    }
}
