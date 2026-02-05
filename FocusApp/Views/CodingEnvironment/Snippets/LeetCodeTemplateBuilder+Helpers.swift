import Foundation

extension LeetCodeTemplateBuilder {
    static func swiftDefaultReturn(for type: LeetCodeValueType) -> String? {
        switch type {
        case .void:
            return nil
        case .int:
            return "return 0"
        case .double:
            return "return 0.0"
        case .bool:
            return "return false"
        case .string:
            return "return \"\""
        case .character:
            return "return \" \""
        case .list:
            return "return []"
        case .dictionary:
            return "return [:]"
        case .listNode, .treeNode:
            return "return nil"
        case .unknown:
            return "return \"TODO\""
        }
    }

    static func collectTypes(params: [LeetCodeMetaParam], returnType: LeetCodeValueType) -> [LeetCodeValueType] {
        var types = params.map { LeetCodeValueType(raw: $0.type) }
        types.append(returnType)
        return types
    }

    static func collectTypes(methods: [LeetCodeMetaMethod]) -> [LeetCodeValueType] {
        var types: [LeetCodeValueType] = []
        for method in methods {
            types.append(contentsOf: method.params.map { LeetCodeValueType(raw: $0.type) })
            if let returnType = method.returnType {
                types.append(LeetCodeValueType(raw: returnType.type))
            }
        }
        return types
    }

    static func swiftSupportClasses(typesUsed: [LeetCodeValueType]) -> String {
        let needsListNode = typesUsed.contains { $0.needsListNode }
        let needsTreeNode = typesUsed.contains { $0.needsTreeNode }
        var lines: [String] = []
        if needsListNode {
            lines.append("final class ListNode {")
            lines.append("    var val: Int")
            lines.append("    var next: ListNode?")
            lines.append("    init(_ val: Int) { self.val = val; self.next = nil }")
            lines.append("    init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next }")
            lines.append("}")
        }
        if needsTreeNode {
            if !lines.isEmpty { lines.append("") }
            lines.append("final class TreeNode {")
            lines.append("    var val: Int")
            lines.append("    var left: TreeNode?")
            lines.append("    var right: TreeNode?")
            lines.append("    init(_ val: Int) { self.val = val; self.left = nil; self.right = nil }")
            lines.append(
                "    init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) { self.val = val; "
                    + "self.left = left; self.right = right }"
            )
            lines.append("}")
        }
        return lines.joined(separator: "\n")
    }

    static func pythonSupportClasses(typesUsed: [LeetCodeValueType]) -> String {
        let needsListNode = typesUsed.contains { $0.needsListNode }
        let needsTreeNode = typesUsed.contains { $0.needsTreeNode }
        var lines: [String] = []
        if needsListNode {
            lines.append("class ListNode:")
            lines.append("    def __init__(self, val=0, next=None):")
            lines.append("        self.val = val")
            lines.append("        self.next = next")
        }
        if needsTreeNode {
            if !lines.isEmpty { lines.append("") }
            lines.append("class TreeNode:")
            lines.append("    def __init__(self, val=0, left=None, right=None):")
            lines.append("        self.val = val")
            lines.append("        self.left = left")
            lines.append("        self.right = right")
        }
        return lines.joined(separator: "\n")
    }

    static func pythonTypingImports(typesUsed: [LeetCodeValueType]) -> String {
        let needsList = typesUsed.contains { type in
            if case .list = type { return true }
            return false
        }
        let needsOptional = typesUsed.contains { $0 == .listNode || $0 == .treeNode }
        let needsDict = typesUsed.contains { type in
            if case .dictionary = type { return true }
            return false
        }
        let needsAny = typesUsed.contains { type in
            if case .unknown = type { return true }
            return false
        }
        var items: [String] = []
        if needsList {
            items.append("List")
        }
        if needsDict {
            items.append("Dict")
        }
        if needsOptional {
            items.append("Optional")
        }
        if needsAny {
            items.append("Any")
        }
        guard !items.isEmpty else { return "" }
        return "from typing import \(items.joined(separator: ", "))"
    }

    static func swiftSafeIdentifier(_ name: String, index: Int) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
        let fallback = cleaned.isEmpty ? "arg\(index + 1)" : cleaned
        let keywords: Set<String> = [
            "class", "struct", "enum", "protocol", "extension", "func", "let", "var", "if", "else",
            "switch", "case", "default", "break", "for", "while", "do", "return", "import", "as",
            "try", "catch", "throw", "throws", "rethrows", "public", "private", "internal", "fileprivate",
            "open", "static", "final", "inout", "where", "nil", "true", "false"
        ]
        if keywords.contains(fallback) {
            return "`\(fallback)`"
        }
        return fallback
    }

    static func pythonSafeIdentifier(_ name: String, index: Int) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
        let fallback = cleaned.isEmpty ? "arg\(index + 1)" : cleaned
        let keywords: Set<String> = [
            "class", "def", "return", "if", "elif", "else", "for", "while", "try", "except",
            "raise", "import", "from", "as", "pass", "break", "continue", "with", "lambda", "yield",
            "global", "nonlocal", "True", "False", "None"
        ]
        if keywords.contains(fallback) {
            return "\(fallback)_"
        }
        return fallback
    }
}
