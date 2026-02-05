import Foundation

extension LeetCodeExecutionWrapper {
    static func wrapPython(code: String, meta: LeetCodeMetaData) -> String {
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

        let listNodeHelpers = needsListNode ? pythonListNodeHelpers : ""
        let treeNodeHelpers = needsTreeNode ? pythonTreeNodeHelpers : ""

        let argLines = params.enumerated().map { index, param -> String in
            let type = LeetCodeValueType(raw: param.type)
            let valueExpr = "args[\(index)]"
            return "    arg\(index) = \(pythonConversionExpression(type, valueExpr: valueExpr))"
        }
        let callArgs = params.indices.map { "arg\($0)" }.joined(separator: ", ")
        let methodName = LeetCodeTemplateBuilder.pythonSafeIdentifier(meta.name ?? "solve", index: 0)
        let callLine = "    result = solution.\(methodName)(\(callArgs))"
        let outputExpression = pythonOutputExpression(for: returnType)
        let paramNamesLiteral = pythonParamNamesLiteral(params)

        let runner = [
            pythonRunnerPrelude(paramNamesLiteral: paramNamesLiteral),
            pythonRunnerConversions(listNodeHelpers: listNodeHelpers, treeNodeHelpers: treeNodeHelpers),
            pythonRunnerMain(
                paramsCount: params.count,
                arguments: argLines,
                callLine: callLine,
                outputExpression: outputExpression
            )
        ].joined()

        let wrapper = """
        \(support.isEmpty ? "" : "\n\(support)\n")
        \(runner)
        """

        return "\(code)\n\(wrapper)"
    }

    private static func pythonParamNamesLiteral(_ params: [LeetCodeMetaParam]) -> String {
        params.enumerated().map { index, param in
            let name = param.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let resolved = name.isEmpty ? "arg\(index + 1)" : name
            let escaped = resolved.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        }.joined(separator: ", ")
    }

    private static let pythonListNodeHelpers = """
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
        """

    private static let pythonTreeNodeHelpers = """
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
        """

    static func pythonConversionExpression(_ type: LeetCodeValueType, valueExpr: String) -> String {
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
        case .dictionary(let keyType, let valueType):
            let keyExpr = pythonConversionExpression(keyType, valueExpr: "key")
            let valueConv = pythonConversionExpression(valueType, valueExpr: "value")
            return "_to_dict(\(valueExpr), lambda key: \(keyExpr), lambda value: \(valueConv))"
        case .listNode:
            return "_to_listnode(\(valueExpr))"
        case .treeNode:
            return "_to_treenode(\(valueExpr))"
        case .void, .unknown:
            return valueExpr
        }
    }

    static func pythonOutputExpression(for type: LeetCodeValueType) -> String {
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
}
