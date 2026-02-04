import Foundation

extension CodingEnvironmentPresenter {
    func selectProblem(_ item: CodingProblemItem) {
        selectProblem(item.problem, at: item.index, day: item.dayId)
    }

    func initialCode(for problem: Problem, language: ProgrammingLanguage) -> String {
        if let storedCode = loadStoredCode(for: problem, language: language) {
            let trimmed = storedCode.trimmingCharacters(in: .whitespacesAndNewlines)
            let defaultTrimmed = language.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed != defaultTrimmed {
                return storedCode
            }
        }

        if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
           let cached = problemContentCache[slug],
           let snippet = snippetForLanguage(language, from: cached) {
            return snippet
        }

        if let slug = LeetCodeSlugExtractor.extractSlug(from: problem.url),
           let cached = problemContentCache[slug],
           let template = LeetCodeTemplateBuilder.template(for: cached, language: language) {
            return template
        }

        return ""
    }

    func applySnippetIfNeeded(from content: QuestionContent) {
        guard let problem = selectedProblem else { return }
        let defaultTrimmed = language.defaultTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        if let storedCode = loadStoredCode(for: problem, language: language) {
            let trimmed = storedCode.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed != defaultTrimmed {
                return
            }
        }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && trimmed != defaultTrimmed {
            return
        }
        if let snippet = snippetForLanguage(language, from: content) {
            setCode(snippet)
            return
        }
        if let template = LeetCodeTemplateBuilder.template(for: content, language: language) {
            setCode(template)
        }
    }

    func snippetForLanguage(_ language: ProgrammingLanguage, from content: QuestionContent) -> String? {
        for slug in language.snippetSlugs {
            if let snippet = content.codeSnippets[slug] {
                return snippet
            }
        }
        return nil
    }
}

struct LeetCodeTemplateBuilder {
    static func template(for content: QuestionContent, language: ProgrammingLanguage) -> String? {
        guard let meta = LeetCodeMetaData.decode(from: content.metaData) else { return nil }
        return template(for: meta, language: language)
    }

    static func template(for meta: LeetCodeMetaData, language: ProgrammingLanguage) -> String? {
        if meta.isClassDesign {
            return classDesignTemplate(for: meta, language: language)
        }

        guard let name = meta.name, !name.isEmpty else { return nil }
        let params = meta.primaryParams
        let returnType = LeetCodeValueType(raw: meta.returnType?.type ?? "void")

        switch language {
        case .swift:
            return swiftFunctionTemplate(name: name, params: params, returnType: returnType)
        case .python:
            return pythonFunctionTemplate(name: name, params: params, returnType: returnType)
        }
    }

    private static func classDesignTemplate(for meta: LeetCodeMetaData, language: ProgrammingLanguage) -> String? {
        guard let className = meta.className, let methods = meta.methods, !methods.isEmpty else { return nil }
        switch language {
        case .swift:
            return swiftClassDesignTemplate(className: className, methods: methods)
        case .python:
            return pythonClassDesignTemplate(className: className, methods: methods)
        }
    }

    private static func swiftFunctionTemplate(name: String, params: [LeetCodeMetaParam], returnType: LeetCodeValueType) -> String {
        let typesUsed = collectTypes(params: params, returnType: returnType)
        let support = swiftSupportClasses(typesUsed: typesUsed)
        let parameters = swiftParameterList(params)
        let returnSignature = returnType == .void ? "" : " -> \(returnType.swiftType)"
        let returnLine = swiftDefaultReturn(for: returnType)

        var lines: [String] = []
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class Solution {")
        lines.append("    func \(swiftSafeIdentifier(name, index: 0))\(parameters)\(returnSignature) {")
        lines.append("        // TODO: Implement")
        if let returnLine {
            lines.append("        \(returnLine)")
        }
        lines.append("    }")
        lines.append("}")

        return lines.joined(separator: "\n")
    }

    private static func pythonFunctionTemplate(name: String, params: [LeetCodeMetaParam], returnType: LeetCodeValueType) -> String {
        let typesUsed = collectTypes(params: params, returnType: returnType)
        let support = pythonSupportClasses(typesUsed: typesUsed)
        let imports = pythonTypingImports(typesUsed: typesUsed)
        let parameterList = pythonParameterList(params)
        let returnSignature = returnType == .void ? "" : " -> \(returnType.pythonType)"

        var lines: [String] = []
        if !imports.isEmpty {
            lines.append(imports)
        }
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class Solution:")
        lines.append("    def \(pythonSafeIdentifier(name, index: 0))(\(parameterList))\(returnSignature):")
        lines.append("        # TODO: Implement")
        lines.append("        pass")

        return lines.joined(separator: "\n")
    }

    private static func swiftClassDesignTemplate(className: String, methods: [LeetCodeMetaMethod]) -> String {
        let typesUsed = collectTypes(methods: methods)
        let support = swiftSupportClasses(typesUsed: typesUsed)

        var lines: [String] = []
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class \(swiftSafeIdentifier(className, index: 0)) {")

        for (index, method) in methods.enumerated() {
            if method.name == className {
                let params = swiftParameterList(method.params)
                lines.append("    init\(params) {")
                lines.append("        // TODO: Initialize")
                lines.append("    }")
            } else {
                let returnType = LeetCodeValueType(raw: method.returnType?.type ?? "void")
                let returnSignature = returnType == .void ? "" : " -> \(returnType.swiftType)"
                let returnLine = swiftDefaultReturn(for: returnType)
                let parameters = swiftParameterList(method.params)
                let methodName = swiftSafeIdentifier(method.name, index: index)
                lines.append("    func \(methodName)\(parameters)\(returnSignature) {")
                lines.append("        // TODO: Implement")
                if let returnLine {
                    lines.append("        \(returnLine)")
                }
                lines.append("    }")
            }
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }

    private static func pythonClassDesignTemplate(className: String, methods: [LeetCodeMetaMethod]) -> String {
        let typesUsed = collectTypes(methods: methods)
        let support = pythonSupportClasses(typesUsed: typesUsed)
        let imports = pythonTypingImports(typesUsed: typesUsed)

        var lines: [String] = []
        if !imports.isEmpty {
            lines.append(imports)
        }
        if !support.isEmpty {
            lines.append(support)
        }
        lines.append("class \(pythonSafeIdentifier(className, index: 0)):")

        for (index, method) in methods.enumerated() {
            if method.name == className {
                let parameters = pythonParameterList(method.params)
                lines.append("    def __init__(\(parameters)):")
                lines.append("        # TODO: Initialize")
                lines.append("        pass")
            } else {
                let returnType = LeetCodeValueType(raw: method.returnType?.type ?? "void")
                let returnSignature = returnType == .void ? "" : " -> \(returnType.pythonType)"
                let parameters = pythonParameterList(method.params)
                let methodName = pythonSafeIdentifier(method.name, index: index)
                lines.append("    def \(methodName)(\(parameters))\(returnSignature):")
                lines.append("        # TODO: Implement")
                lines.append("        pass")
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func swiftParameterList(_ params: [LeetCodeMetaParam]) -> String {
        guard !params.isEmpty else { return "()" }
        let signature = params.enumerated().map { index, param -> String in
            let name = swiftSafeIdentifier(param.name ?? "arg\(index + 1)", index: index)
            let type = LeetCodeValueType(raw: param.type).swiftType
            return "_ \(name): \(type)"
        }.joined(separator: ", ")
        return "(\(signature))"
    }

    private static func pythonParameterList(_ params: [LeetCodeMetaParam]) -> String {
        let items = params.enumerated().map { index, param -> String in
            let name = pythonSafeIdentifier(param.name ?? "arg\(index + 1)", index: index)
            let type = LeetCodeValueType(raw: param.type).pythonType
            return "\(name): \(type)"
        }
        let list = (["self"] + items).joined(separator: ", ")
        return list
    }

    private static func swiftDefaultReturn(for type: LeetCodeValueType) -> String? {
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
        case .listNode, .treeNode:
            return "return nil"
        case .unknown:
            return "return \"TODO\""
        }
    }

    private static func collectTypes(params: [LeetCodeMetaParam], returnType: LeetCodeValueType) -> [LeetCodeValueType] {
        var types = params.map { LeetCodeValueType(raw: $0.type) }
        types.append(returnType)
        return types
    }

    private static func collectTypes(methods: [LeetCodeMetaMethod]) -> [LeetCodeValueType] {
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
            lines.append("    init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) { self.val = val; self.left = left; self.right = right }")
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

    private static func pythonTypingImports(typesUsed: [LeetCodeValueType]) -> String {
        var needsList = typesUsed.contains { type in
            if case .list = type { return true }
            return false
        }
        let needsOptional = typesUsed.contains { $0 == .listNode || $0 == .treeNode }
        let needsAny = typesUsed.contains { type in
            if case .unknown = type { return true }
            return false
        }
        var items: [String] = []
        if needsList {
            items.append("List")
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

struct LeetCodeExecutionWrapper {
    static func wrap(code: String, language: ProgrammingLanguage, meta: LeetCodeMetaData) -> String {
        guard shouldWrap(code: code, language: language, meta: meta) else { return code }
        switch language {
        case .swift:
            return wrapSwift(code: code, meta: meta)
        case .python:
            return wrapPython(code: code, meta: meta)
        }
    }

    private static func shouldWrap(code: String, language: ProgrammingLanguage, meta: LeetCodeMetaData) -> Bool {
        if meta.isClassDesign { return false }
        guard let name = meta.name, !name.isEmpty else { return false }
        let marker = language == .swift ? "// FocusApp LeetCode Runner" : "# FocusApp LeetCode Runner"
        if code.contains(marker) { return false }
        switch language {
        case .swift:
            return code.contains("class Solution") || code.contains("struct Solution")
        case .python:
            return code.contains("class Solution")
        }
    }

    private static func wrapSwift(code: String, meta: LeetCodeMetaData) -> String {
        let params = meta.primaryParams
        let returnType = LeetCodeValueType(raw: meta.returnType?.type ?? "void")
        let typesUsed = params.map { LeetCodeValueType(raw: $0.type) } + [returnType]
        let needsListNode = typesUsed.contains { $0.needsListNode }
        let needsTreeNode = typesUsed.contains { $0.needsTreeNode }
        let needsListNodeSupport = needsListNode && !containsTypeDefinition(in: code, typeName: "ListNode")
        let needsTreeNodeSupport = needsTreeNode && !containsTypeDefinition(in: code, typeName: "TreeNode")

        let supportTypes = [needsListNodeSupport ? LeetCodeValueType.listNode : nil,
                            needsTreeNodeSupport ? LeetCodeValueType.treeNode : nil].compactMap { $0 }
        let support = supportTypes.isEmpty ? "" : LeetCodeTemplateBuilder.swiftSupportClasses(typesUsed: supportTypes)

        let listNodeHelpers = needsListNode ? """
        func toListNode(_ value: Any) -> ListNode? {
            guard let array = value as? [Any] else { return nil }
            let dummy = ListNode(0)
            var current: ListNode? = dummy
            for item in array {
                let node = ListNode(toInt(item))
                current?.next = node
                current = node
            }
            return dummy.next
        }

        func listNodeToArray(_ node: ListNode?) -> [Int] {
            var result: [Int] = []
            var current = node
            while let node = current {
                result.append(node.val)
                current = node.next
            }
            return result
        }
        """ : ""

        let treeNodeHelpers = needsTreeNode ? """
        func toTreeNode(_ value: Any) -> TreeNode? {
            guard let array = value as? [Any], !array.isEmpty else { return nil }
            var nodes: [TreeNode?] = array.map { item in
                if item is NSNull { return nil }
                return TreeNode(toInt(item))
            }
            var index = 0
            var childIndex = 1
            while childIndex < nodes.count {
                if let node = nodes[index] {
                    if childIndex < nodes.count {
                        node.left = nodes[childIndex]
                        childIndex += 1
                    }
                    if childIndex < nodes.count {
                        node.right = nodes[childIndex]
                        childIndex += 1
                    }
                }
                index += 1
            }
            return nodes.first ?? nil
        }

        func treeNodeToArray(_ root: TreeNode?) -> [Any] {
            guard let root else { return [] }
            var result: [Any] = []
            var queue: [TreeNode?] = [root]
            while !queue.isEmpty {
                let node = queue.removeFirst()
                if let node {
                    result.append(node.val)
                    queue.append(node.left)
                    queue.append(node.right)
                } else {
                    result.append(NSNull())
                }
            }
            while let last = result.last, last is NSNull {
                result.removeLast()
            }
            return result
        }
        """ : ""

        let arguments = params.enumerated().map { index, param -> String in
            let type = LeetCodeValueType(raw: param.type)
            return "let arg\(index) = \(swiftConversionExpression(type, valueExpr: "valueAt(args, \(index))"))"
        }

        let callArgs = params.indices.map { "arg\($0)" }.joined(separator: ", ")
        let methodName = LeetCodeTemplateBuilder.swiftSafeIdentifier(meta.name ?? "solve", index: 0)
        let callLine = "let result = solution.\(methodName)\(callArgs.isEmpty ? "()" : "(\(callArgs))")"
        let outputExpression = swiftOutputExpression(for: returnType)
        let paramNamesLiteral = params.enumerated().map { index, param in
            let name = param.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolved = (name?.isEmpty == false) ? name! : "arg\(index + 1)"
            let escaped = resolved.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        }.joined(separator: ", ")

        let wrapper = """
        \(support.isEmpty ? "" : "\n\(support)\n")
        // FocusApp LeetCode Runner
        let paramNames = [\(paramNamesLiteral)]

        func parseKeyValueInput(_ input: String, paramNames: [String]) -> [String: Any] {
            guard !paramNames.isEmpty else { return [:] }
            let pattern = "\\\\b([A-Za-z_][A-Za-z0-9_]*)\\\\b\\\\s*="
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [:] }
            let nsInput = input as NSString
            let matches = regex.matches(in: input, range: NSRange(location: 0, length: nsInput.length))
            guard !matches.isEmpty else { return [:] }
            var results: [String: Any] = [:]
            for (idx, match) in matches.enumerated() {
                guard match.numberOfRanges >= 2 else { continue }
                let name = nsInput.substring(with: match.range(at: 1))
                let valueStart = match.range.location + match.range.length
                let valueEnd = idx + 1 < matches.count ? matches[idx + 1].range.location : nsInput.length
                let length = max(0, valueEnd - valueStart)
                let rawValue = nsInput.substring(with: NSRange(location: valueStart, length: length))
                let cleaned = rawValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: ","))
                guard !cleaned.isEmpty else { continue }
                if let data = cleaned.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    results[name] = json
                } else {
                    results[name] = cleaned
                }
            }
            var filtered: [String: Any] = [:]
            for name in paramNames {
                if let value = results[name] {
                    filtered[name] = value
                }
            }
            return filtered
        }

        func parseArgs(from input: String, expectedCount: Int) -> [Any] {
            let trimmed = input
                .replacingOccurrences(of: "Input:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return [] }
            let keyValues = parseKeyValueInput(trimmed, paramNames: paramNames)
            if !keyValues.isEmpty {
                let ordered = paramNames.compactMap { keyValues[$0] }
                return ordered
            }
            if let data = trimmed.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) {
                if expectedCount == 1 {
                    return [json]
                }
                if let array = json as? [Any] { return array }
                return [json]
            }
            let lines = trimmed.split(whereSeparator: { $0.isNewline }).map(String.init)
            var values: [Any] = []
            for line in lines {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    values.append(json)
                } else {
                    values.append(line)
                }
            }
            if expectedCount == 1 {
                if values.count == 1 { return [values[0]] }
                if values.isEmpty { return [] }
                return [values]
            }
            if expectedCount > 0 && values.count > expectedCount {
                return Array(values.prefix(expectedCount))
            }
            return values
        }

        func valueAt(_ args: [Any], _ index: Int) -> Any {
            guard args.indices.contains(index) else { return NSNull() }
            return args[index]
        }

        func toInt(_ value: Any) -> Int {
            if let intValue = value as? Int { return intValue }
            if let doubleValue = value as? Double { return Int(doubleValue) }
            if let stringValue = value as? String, let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return intValue
            }
            return 0
        }

        func toDouble(_ value: Any) -> Double {
            if let doubleValue = value as? Double { return doubleValue }
            if let intValue = value as? Int { return Double(intValue) }
            if let stringValue = value as? String, let doubleValue = Double(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return doubleValue
            }
            return 0.0
        }

        func toBool(_ value: Any) -> Bool {
            if let boolValue = value as? Bool { return boolValue }
            if let stringValue = value as? String {
                let lowered = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return lowered == "true" || lowered == "1"
            }
            if let intValue = value as? Int { return intValue != 0 }
            return false
        }

        func toString(_ value: Any) -> String {
            if let stringValue = value as? String { return stringValue }
            return String(describing: value)
        }

        func toCharacter(_ value: Any) -> Character {
            let stringValue = toString(value)
            return stringValue.first ?? " "
        }

        func toArray<T>(_ value: Any, _ transform: (Any) -> T) -> [T] {
            guard let array = value as? [Any] else { return [] }
            return array.map(transform)
        }
        \(listNodeHelpers)
        \(treeNodeHelpers)

        func jsonString(from value: Any) -> String {
            if value is NSNull {
                return "null"
            }
            if JSONSerialization.isValidJSONObject(value),
               let data = try? JSONSerialization.data(withJSONObject: value),
               let string = String(data: data, encoding: .utf8) {
                return string
            }
            if let string = value as? String {
                if let data = try? JSONSerialization.data(withJSONObject: [string]),
                   let json = String(data: data, encoding: .utf8),
                   json.count >= 2 {
                    return String(json.dropFirst().dropLast())
                }
                return string
            }
            return String(describing: value)
        }

        let inputData = FileHandle.standardInput.readDataToEndOfFile()
        let input = String(data: inputData, encoding: .utf8) ?? ""
        let args = parseArgs(from: input, expectedCount: \(params.count))
        let solution = Solution()
        \(arguments.joined(separator: "\n"))
        \(callLine)
        let output: Any = \(outputExpression)
        print(jsonString(from: output))
        """

        return "import Foundation\n\n\(code)\n\n\(wrapper)"
    }

    private static func wrapPython(code: String, meta: LeetCodeMetaData) -> String {
        let params = meta.primaryParams
        let returnType = LeetCodeValueType(raw: meta.returnType?.type ?? "void")
        let typesUsed = params.map { LeetCodeValueType(raw: $0.type) } + [returnType]
        let needsListNode = typesUsed.contains { $0.needsListNode }
        let needsTreeNode = typesUsed.contains { $0.needsTreeNode }
        let needsListNodeSupport = needsListNode && !containsTypeDefinition(in: code, typeName: "ListNode")
        let needsTreeNodeSupport = needsTreeNode && !containsTypeDefinition(in: code, typeName: "TreeNode")

        let supportTypes = [needsListNodeSupport ? LeetCodeValueType.listNode : nil,
                            needsTreeNodeSupport ? LeetCodeValueType.treeNode : nil].compactMap { $0 }
        let support = supportTypes.isEmpty ? "" : LeetCodeTemplateBuilder.pythonSupportClasses(typesUsed: supportTypes)

        let listNodeHelpers = needsListNode ? """
        def _to_listnode(value):
            if not isinstance(value, list):
                return None
            dummy = ListNode(0)
            current = dummy
            for item in value:
                current.next = ListNode(_to_int(item))
                current = current.next
            return dummy.next

        def _listnode_to_list(node):
            result = []
            current = node
            while current:
                result.append(current.val)
                current = current.next
            return result
        """ : ""

        let treeNodeHelpers = needsTreeNode ? """
        def _to_treenode(value):
            if not isinstance(value, list) or not value:
                return None
            nodes = [None if v is None else TreeNode(_to_int(v)) for v in value]
            idx = 0
            child = 1
            while child < len(nodes):
                node = nodes[idx]
                if node is not None:
                    if child < len(nodes):
                        node.left = nodes[child]
                        child += 1
                    if child < len(nodes):
                        node.right = nodes[child]
                        child += 1
                idx += 1
            return nodes[0]

        def _treenode_to_list(root):
            if root is None:
                return []
            result = []
            queue = [root]
            while queue:
                node = queue.pop(0)
                if node is None:
                    result.append(None)
                else:
                    result.append(node.val)
                    queue.append(node.left)
                    queue.append(node.right)
            while result and result[-1] is None:
                result.pop()
            return result
        """ : ""

        let argLines = params.enumerated().map { index, param -> String in
            let type = LeetCodeValueType(raw: param.type)
            return "    arg\(index) = \(pythonConversionExpression(type, valueExpr: "args[\(index)]"))"
        }
        let callArgs = params.indices.map { "arg\($0)" }.joined(separator: ", ")
        let methodName = LeetCodeTemplateBuilder.pythonSafeIdentifier(meta.name ?? "solve", index: 0)
        let callLine = "    result = solution.\(methodName)(\(callArgs))"
        let outputExpression = pythonOutputExpression(for: returnType)
        let paramNamesLiteral = params.enumerated().map { index, param in
            let name = param.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolved = (name?.isEmpty == false) ? name! : "arg\(index + 1)"
            let escaped = resolved.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        }.joined(separator: ", ")

        let wrapper = """
        \(support.isEmpty ? "" : "\n\(support)\n")
        # FocusApp LeetCode Runner
        import json
        import sys
        from typing import List, Optional
        PARAM_NAMES = [\(paramNamesLiteral)]

        def _parse_kv_input(raw, param_names):
            import re
            if not param_names:
                return {}
            matches = list(re.finditer(r"\\b([A-Za-z_][A-Za-z0-9_]*)\\b\\s*=", raw))
            if not matches:
                return {}
            results = {}
            for idx, match in enumerate(matches):
                name = match.group(1)
                start = match.end()
                end = matches[idx + 1].start() if idx + 1 < len(matches) else len(raw)
                value = raw[start:end].strip().strip(",")
                if not value:
                    continue
                try:
                    results[name] = json.loads(value)
                except json.JSONDecodeError:
                    results[name] = value
            return {name: results[name] for name in param_names if name in results}

        def _parse_args(raw, expected_count):
            raw = raw.strip()
            if not raw:
                return []
            if raw.lower().startswith("input:"):
                raw = raw[6:].strip()
            kv = _parse_kv_input(raw, PARAM_NAMES)
            if kv:
                return [kv[name] for name in PARAM_NAMES if name in kv]
            try:
                data = json.loads(raw)
                if expected_count == 1:
                    return [data]
                if isinstance(data, list):
                    return data
                return [data]
            except json.JSONDecodeError:
                lines = [line for line in raw.splitlines() if line.strip()]
                values = []
                for line in lines:
                    try:
                        values.append(json.loads(line))
                    except json.JSONDecodeError:
                        values.append(line)
                if expected_count == 1:
                    if len(values) == 1:
                        return [values[0]]
                    if not values:
                        return []
                    return [values]
                if expected_count and len(values) > expected_count:
                    return values[:expected_count]
                return values

        def _to_int(value):
            if isinstance(value, bool):
                return int(value)
            if isinstance(value, (int, float)):
                return int(value)
            try:
                return int(str(value).strip())
            except ValueError:
                return 0

        def _to_float(value):
            if isinstance(value, (int, float)):
                return float(value)
            try:
                return float(str(value).strip())
            except ValueError:
                return 0.0

        def _to_bool(value):
            if isinstance(value, bool):
                return value
            if isinstance(value, (int, float)):
                return value != 0
            return str(value).strip().lower() in {"true", "1"}

        def _to_str(value):
            return str(value)

        def _to_list(value, transform):
            if not isinstance(value, list):
                return []
            return [transform(item) for item in value]
        \(listNodeHelpers)
        \(treeNodeHelpers)

        def _serialize_output(value):
            return value

        def _run():
            raw = sys.stdin.read()
            args = _parse_args(raw, \(params.count))
            solution = Solution()
        \(argLines.joined(separator: "\n"))
        \(callLine)
            output = \(outputExpression)
            print(json.dumps(output))

        if __name__ == "__main__":
            _run()
        """

        return "\(code)\n\(wrapper)"
    }

    private static func swiftConversionExpression(_ type: LeetCodeValueType, valueExpr: String) -> String {
        switch type {
        case .int:
            return "toInt(\(valueExpr))"
        case .double:
            return "toDouble(\(valueExpr))"
        case .bool:
            return "toBool(\(valueExpr))"
        case .string:
            return "toString(\(valueExpr))"
        case .character:
            return "toCharacter(\(valueExpr))"
        case .list(let inner):
            let innerExpr = swiftConversionExpression(inner, valueExpr: "$0")
            return "toArray(\(valueExpr)) { \(innerExpr) }"
        case .listNode:
            return "toListNode(\(valueExpr))"
        case .treeNode:
            return "toTreeNode(\(valueExpr))"
        case .void, .unknown:
            return valueExpr
        }
    }

    private static func swiftOutputExpression(for type: LeetCodeValueType) -> String {
        switch type {
        case .void:
            return "NSNull()"
        case .listNode:
            return "listNodeToArray(result)"
        case .treeNode:
            return "treeNodeToArray(result)"
        default:
            return "result"
        }
    }

    private static func pythonConversionExpression(_ type: LeetCodeValueType, valueExpr: String) -> String {
        switch type {
        case .int:
            return "_to_int(\(valueExpr))"
        case .double:
            return "_to_float(\(valueExpr))"
        case .bool:
            return "_to_bool(\(valueExpr))"
        case .string, .character:
            return "_to_str(\(valueExpr))"
        case .list(let inner):
            let innerExpr = pythonConversionExpression(inner, valueExpr: "item")
            return "_to_list(\(valueExpr), lambda item: \(innerExpr))"
        case .listNode:
            return "_to_listnode(\(valueExpr))"
        case .treeNode:
            return "_to_treenode(\(valueExpr))"
        case .void, .unknown:
            return valueExpr
        }
    }

    private static func pythonOutputExpression(for type: LeetCodeValueType) -> String {
        switch type {
        case .void:
            return "None"
        case .listNode:
            return "_listnode_to_list(result)"
        case .treeNode:
            return "_treenode_to_list(result)"
        default:
            return "result"
        }
    }

    private static func containsTypeDefinition(in code: String, typeName: String) -> Bool {
        let stripped = stripCommentsAndStrings(from: code)
        let escaped = NSRegularExpression.escapedPattern(for: typeName)
        let pattern = "\\b(class|struct)\\s+\\(escaped)\\b"
        return stripped.range(of: pattern, options: .regularExpression) != nil
    }

    private static func stripCommentsAndStrings(from code: String) -> String {
        var result = ""
        var index = code.startIndex
        var inSingleLineComment = false
        var inMultiLineComment = false
        var inString = false
        var previous: Character? = nil

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
