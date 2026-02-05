import Foundation

extension LeetCodeExecutionWrapper {
    struct TypeDefinitionInfo {
        let kind: String
        let body: String
    }

    static func listNodeInitExpression(in code: String, valueExpr: String, nextExpr: String) -> String {
        guard let info = typeDefinition(named: "ListNode", in: code) else {
            return "ListNode(\(valueExpr))"
        }

        let body = info.body
        let hasAnyInit = hasPattern("\\binit\\s*\\(", in: body)
        let hasInitUnderscoreMultiple = hasPattern(
            "\\binit\\s*\\(\\s*_\\s*\\w+\\s*:[^\\)]*,\\s*_\\s*\\w+\\s*:",
            in: body
        )
        let hasInitUnderscoreSingle = hasPattern(
            "\\binit\\s*\\(\\s*_\\s*\\w+\\s*:[^,\\)]*\\)",
            in: body
        )
        let hasInitLabeledValNext = hasPattern(
            "\\binit\\s*\\(\\s*val\\s*:[^\\)]*,\\s*next\\s*:",
            in: body
        )
        let hasInitEmpty = hasPattern("\\binit\\s*\\(\\s*\\)", in: body)
        let hasVarVal = hasPattern("\\bvar\\s+val\\b", in: body)
        let hasVarNext = hasPattern("\\bvar\\s+next\\b", in: body)

        if hasInitUnderscoreSingle {
            return "ListNode(\(valueExpr))"
        }
        if hasInitUnderscoreMultiple {
            return "ListNode(\(valueExpr), \(nextExpr))"
        }
        if hasInitLabeledValNext {
            return "ListNode(val: \(valueExpr), next: \(nextExpr))"
        }
        if info.kind == "struct", !hasAnyInit, hasVarVal, hasVarNext {
            return "ListNode(val: \(valueExpr), next: \(nextExpr))"
        }
        if hasInitEmpty, hasVarVal {
            let nextAssignment = hasVarNext ? "node.next = \(nextExpr); " : ""
            return "{ let node = ListNode(); node.val = \(valueExpr); \(nextAssignment)return node }()"
        }
        return "ListNode(\(valueExpr))"
    }

    static func treeNodeInitExpression(
        in code: String,
        valueExpr: String,
        leftExpr: String,
        rightExpr: String
    ) -> String {
        guard let info = typeDefinition(named: "TreeNode", in: code) else {
            return "TreeNode(\(valueExpr))"
        }

        let body = info.body
        let hasAnyInit = hasPattern("\\binit\\s*\\(", in: body)
        let hasInitUnderscoreMultiple = hasPattern(
            "\\binit\\s*\\(\\s*_\\s*\\w+\\s*:[^\\)]*,\\s*_\\s*\\w+\\s*:",
            in: body
        )
        let hasInitUnderscoreSingle = hasPattern(
            "\\binit\\s*\\(\\s*_\\s*\\w+\\s*:[^,\\)]*\\)",
            in: body
        )
        let hasInitLabeledValChildren = hasPattern(
            "\\binit\\s*\\(\\s*val\\s*:[^\\)]*,\\s*left\\s*:[^\\)]*,\\s*right\\s*:",
            in: body
        )
        let hasInitEmpty = hasPattern("\\binit\\s*\\(\\s*\\)", in: body)
        let hasVarVal = hasPattern("\\bvar\\s+val\\b", in: body)
        let hasVarLeft = hasPattern("\\bvar\\s+left\\b", in: body)
        let hasVarRight = hasPattern("\\bvar\\s+right\\b", in: body)

        if hasInitUnderscoreSingle {
            return "TreeNode(\(valueExpr))"
        }
        if hasInitUnderscoreMultiple {
            return "TreeNode(\(valueExpr), \(leftExpr), \(rightExpr))"
        }
        if hasInitLabeledValChildren {
            return "TreeNode(val: \(valueExpr), left: \(leftExpr), right: \(rightExpr))"
        }
        if info.kind == "struct", !hasAnyInit, hasVarVal, hasVarLeft, hasVarRight {
            return "TreeNode(val: \(valueExpr), left: \(leftExpr), right: \(rightExpr))"
        }
        if hasInitEmpty, hasVarVal {
            let leftAssignment = hasVarLeft ? "node.left = \(leftExpr); " : ""
            let rightAssignment = hasVarRight ? "node.right = \(rightExpr); " : ""
            return "{ let node = TreeNode(); node.val = \(valueExpr); \(leftAssignment)\(rightAssignment)return node }()"
        }
        return "TreeNode(\(valueExpr))"
    }

    static func typeDefinition(named name: String, in code: String) -> TypeDefinitionInfo? {
        let stripped = stripCommentsAndStrings(from: code)
        let pattern = "\\b(class|struct)\\s+\\(NSRegularExpression.escapedPattern(for: name))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(location: 0, length: (stripped as NSString).length)
        guard let match = regex.firstMatch(in: stripped, options: [], range: range) else { return nil }
        guard match.numberOfRanges >= 2 else { return nil }

        let kind = (stripped as NSString).substring(with: match.range(at: 1))
        let matchEnd = match.range.location + match.range.length
        guard let braceStart = stripped[stripIndex(stripped, offset: matchEnd)...].firstIndex(of: "{") else {
            return nil
        }
        var depth = 0
        var index = braceStart
        while index < stripped.endIndex {
            let char = stripped[index]
            if char == "{" {
                depth += 1
            } else if char == "}" {
                depth -= 1
                if depth == 0 {
                    let bodyStart = stripped.index(after: braceStart)
                    let body = String(stripped[bodyStart..<index])
                    return TypeDefinitionInfo(kind: kind, body: body)
                }
            }
            index = stripped.index(after: index)
        }
        return nil
    }

    static func stripIndex(_ value: String, offset: Int) -> String.Index {
        value.index(value.startIndex, offsetBy: min(max(offset, 0), value.count))
    }

    static func hasPattern(_ pattern: String, in text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }

    static func containsTypeDefinition(in code: String, typeName: String) -> Bool {
        let stripped = stripCommentsAndStrings(from: code)
        let escaped = NSRegularExpression.escapedPattern(for: typeName)
        let pattern = "\\b(class|struct)\\s+\(escaped)\\b"
        return stripped.range(of: pattern, options: .regularExpression) != nil
    }

    static func stripCommentsAndStrings(from code: String) -> String {
        var result = ""
        var index = code.startIndex
        var inSingleLineComment = false
        var inMultiLineComment = false
        var inString = false
        var previous: Character?

        while index < code.endIndex {
            let char = code[index]
            let nextIndex = code.index(after: index)
            let nextChar = nextIndex < code.endIndex ? code[nextIndex] : nil

            if inSingleLineComment {
                if char == "\n" {
                    inSingleLineComment = false
                    result.append(char)
                }
                index = nextIndex
                previous = char
                continue
            }

            if inMultiLineComment {
                if char == "*" && nextChar == "/" {
                    inMultiLineComment = false
                    index = code.index(after: nextIndex)
                    previous = nil
                    continue
                }
                index = nextIndex
                previous = char
                continue
            }

            if inString {
                if char == "\"" && previous != "\\" {
                    inString = false
                }
                result.append(" ")
                index = nextIndex
                previous = char
                continue
            }

            if char == "/" && nextChar == "/" {
                inSingleLineComment = true
                index = code.index(after: nextIndex)
                previous = nil
                continue
            }

            if char == "/" && nextChar == "*" {
                inMultiLineComment = true
                index = code.index(after: nextIndex)
                previous = nil
                continue
            }

            if char == "\"" {
                inString = true
                result.append(" ")
                index = nextIndex
                previous = char
                continue
            }

            result.append(char)
            index = nextIndex
            previous = char
        }

        return result
    }
}
