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

    // swiftlint:disable cyclomatic_complexity
    init(raw: String) {
        let normalized = Self.normalizeTypeString(raw)
        let trimmed = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()

        if lower.hasSuffix("[]") {
            let innerRaw = String(trimmed.dropLast(2))
            self = .list(LeetCodeValueType(raw: innerRaw))
            return
        }

        if lower.hasPrefix("list<"), lower.hasSuffix(">") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: 5)
            let end = trimmed.index(before: trimmed.endIndex)
            let innerRaw = String(trimmed[start..<end])
            self = .list(LeetCodeValueType(raw: innerRaw))
            return
        }

        if lower.hasPrefix("map<"), lower.hasSuffix(">") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: 4)
            let end = trimmed.index(before: trimmed.endIndex)
            let innerRaw = String(trimmed[start..<end])
            let parts = Self.splitGenericArguments(innerRaw)
            if parts.count == 2 {
                let keyType = LeetCodeValueType(raw: parts[0])
                let valueType = LeetCodeValueType(raw: parts[1])
                self = .dictionary(keyType, valueType)
                return
            }
        }

        switch lower {
        case "int", "integer", "long", "short", "byte":
            self = .int
        case "double", "float", "decimal":
            self = .double
        case "bool", "boolean":
            self = .bool
        case "string", "str":
            self = .string
        case "char", "character":
            self = .character
        case "void":
            self = .void
        case "listnode":
            self = .listNode
        case "treenode":
            self = .treeNode
        default:
            self = .unknown(trimmed)
        }
    }
    // swiftlint:enable cyclomatic_complexity
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
