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
        let isSingleListNode = params.count == 1 && LeetCodeValueType(raw: params[0].type) == .listNode

        let argLines = params.enumerated().map { index, param -> String in
            let type = LeetCodeValueType(raw: param.type)
            let valueExpr = "args[\(index)]"
            if isSingleListNode, type == .listNode {
                return "    arg\(index) = _to_listnode(\(valueExpr), pos=cycle_pos)"
            }
            return "    arg\(index) = \(pythonConversionExpression(type, valueExpr: valueExpr))"
        }
        let callArgs = params.indices.map { "arg\($0)" }.joined(separator: ", ")
        let methodName = LeetCodeTemplateBuilder.pythonSafeIdentifier(meta.name ?? "solve", index: 0)
        let callLine = "    result = solution.\(methodName)(\(callArgs))"
        let outputExpression = pythonOutputExpression(for: returnType)
        let paramNamesLiteral = pythonParamNamesLiteral(params)
        let setupLines = isSingleListNode ? ["    cycle_pos = _parse_cycle_pos(raw)"] : []

        let traceModule = pythonTraceModule(needsListNode: needsListNode, needsTreeNode: needsTreeNode)

        let runner = [
            pythonRunnerPrelude(paramNamesLiteral: paramNamesLiteral),
            pythonRunnerConversions(listNodeHelpers: listNodeHelpers, treeNodeHelpers: treeNodeHelpers),
            traceModule,
            pythonRunnerMain(
                paramsCount: params.count,
                arguments: argLines,
                callLine: callLine,
                outputExpression: outputExpression,
                setupLines: setupLines,
                paramNamesLiteral: paramNamesLiteral
            )
        ].joined()

        let wrapper = """
        \(support.isEmpty ? "" : "\n\(support)\n")
        \(runner)
        """

        let instrumentedCode = AutoInstrumenter.instrument(
            code: code,
            language: .python,
            paramNames: params.compactMap { $0.name }
        )

        return "\(instrumentedCode)\n\(wrapper)"
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
        def _listnode_payload(value):
            if isinstance(value, dict):
                head = value.get("head") or value.get("list") or value.get("values")
                pos_value = value.get("pos") or value.get("index")
                if isinstance(head, list):
                    pos = _to_int(pos_value) if pos_value is not None else None
                    return head, pos
            if isinstance(value, list):
                if len(value) >= 2 and isinstance(value[0], list):
                    return value[0], _to_int(value[1])
                return value, None
            return [], None

        def _to_listnode(value, pos=None):
            if isinstance(value, list):
                arr = value
                resolved_pos = pos
            else:
                arr, payload_pos = _listnode_payload(value)
                resolved_pos = pos if pos is not None else payload_pos
            if not arr:
                return None
            dummy = ListNode(0)
            current = dummy
            tail = None
            cycle_target = None
            for idx, item in enumerate(arr):
                node = ListNode(_to_int(item))
                current.next = node
                current = node
                tail = node
                if resolved_pos is not None and resolved_pos >= 0 and idx == resolved_pos:
                    cycle_target = node
            if cycle_target is not None and tail is not None:
                tail.next = cycle_target
            return dummy.next

        def _listnode_to_list(node, max_nodes=10000):
            result = []
            current = node
            visited = set()
            count = 0
            while current and count < max_nodes:
                node_id = id(current)
                if node_id in visited:
                    break
                visited.add(node_id)
                result.append(current.val)
                current = current.next
                count += 1
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
