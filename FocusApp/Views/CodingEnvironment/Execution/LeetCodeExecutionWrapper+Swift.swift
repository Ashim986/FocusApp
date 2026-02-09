import Foundation

extension LeetCodeExecutionWrapper {
    private struct SwiftWrapperSupport {
        let supportClasses: String
        let listNodeHelpers: String
        let treeNodeHelpers: String
        let needsListNode: Bool
        let needsTreeNode: Bool
    }

    private struct SwiftInvocationPlan {
        let callLine: String
        let outputExpression: String
        let traceOutputExpression: String
    }

    static func wrapSwift(code: String, meta: LeetCodeMetaData) -> String {
	        let methodName = meta.name ?? "solve"
	        let signature = swiftFunctionSignature(in: code, className: "Solution", methodName: methodName)
	        let params = resolvedSwiftParams(signature: signature, meta: meta)
	        let inoutFlags = signature?.inoutParams ?? Array(repeating: false, count: params.count)
	        let returnType = LeetCodeValueType(raw: signature?.returnType ?? meta.returnType?.type ?? "void")
	        let typesUsed = params.map { LeetCodeValueType(raw: $0.type) } + [returnType]
	        let wrapperSupport = buildSwiftWrapperSupport(code: code, typesUsed: typesUsed)

	        let isSingleListNode = params.count == 1 && LeetCodeValueType(raw: params[0].type) == .listNode
	        let arguments = params.enumerated().map { index, param -> String in
	            let isInout = inoutFlags.indices.contains(index) ? inoutFlags[index] : false
	            let bindingKeyword = isInout ? "var" : "let"
	            let type = LeetCodeValueType(raw: param.type)
	            let valueExpr = "valueAt(args, \(index))"
	            if isSingleListNode, type == .listNode {
	                return "\(bindingKeyword) arg\(index) = toListNode(\(valueExpr), pos: cyclePos)"
	            }
	            return "\(bindingKeyword) arg\(index) = \(swiftConversionExpression(type, valueExpr: valueExpr))"
	        }

	        let invocation = buildSwiftInvocationPlan(
	            params: params,
	            signature: signature,
	            methodName: methodName,
	            inoutFlags: inoutFlags,
	            returnType: returnType
	        )
	        let paramNamesLiteral = swiftParamNamesLiteral(params)

	        let runner = [
	            swiftRunnerPrelude(paramNamesLiteral: paramNamesLiteral),
	            swiftRunnerConversions(
	                listNodeHelpers: wrapperSupport.listNodeHelpers,
	                treeNodeHelpers: wrapperSupport.treeNodeHelpers
	            ),
	            swiftRunnerTrace(
	                needsListNode: wrapperSupport.needsListNode,
	                needsTreeNode: wrapperSupport.needsTreeNode
	            ),
	            swiftRunnerMain(
	                paramsCount: params.count,
	                arguments: arguments,
	                callLine: invocation.callLine,
	                outputExpression: invocation.outputExpression,
	                traceOutputExpression: invocation.traceOutputExpression,
	                setupLines: isSingleListNode ? ["let cyclePos = parseCyclePos(from: input)"] : []
	            )
	        ].joined()

	        let wrapper = """
	        \(wrapperSupport.supportClasses.isEmpty ? "" : "\n\(wrapperSupport.supportClasses)\n")
	        \(runner)
	        """

	        let instrumentedCode = AutoInstrumenter.instrument(
	            code: code,
	            language: .swift,
	            paramNames: params.compactMap { $0.name },
	            entryPointName: methodName
	        )

	        return """
	        import Foundation

	        #sourceLocation(file: "Solution.swift", line: 1)
	        \(instrumentedCode)
	        #sourceLocation()

	        \(wrapper)
	        """
	    }

    private static func buildSwiftInvocationPlan(
        params: [LeetCodeMetaParam],
        signature: SwiftFunctionSignature?,
        methodName: String,
        inoutFlags: [Bool],
        returnType: LeetCodeValueType
    ) -> SwiftInvocationPlan {
        let callArgs = params.indices.map { index -> String in
            let isInout = inoutFlags.indices.contains(index) ? inoutFlags[index] : false
            let argRef = isInout ? "&arg\(index)" : "arg\(index)"
            if let labels = signature?.externalLabels,
               index < labels.count,
               let label = labels[index] {
                return "\(label): \(argRef)"
            }
            return argRef
        }.joined(separator: ", ")

        let resolvedMethodName = signature?.callName
            ?? LeetCodeTemplateBuilder.swiftSafeIdentifier(methodName, index: 0)
        let callSuffix = callArgs.isEmpty ? "()" : "(\(callArgs))"

        // For void+inout functions, use the first inout argument as the output.
        let firstInoutIndex = inoutFlags.firstIndex(of: true)
        let isVoidInout = returnType == .void && firstInoutIndex != nil

        let callLine = isVoidInout
            ? "solution.\(resolvedMethodName)\(callSuffix)"
            : "let result = solution.\(resolvedMethodName)\(callSuffix)"

        let outputExpression: String
        if isVoidInout, let idx = firstInoutIndex {
            outputExpression = "arg\(idx)"
        } else {
            outputExpression = swiftOutputExpression(for: returnType)
        }

        let traceOutputExpression: String
        if isVoidInout, let idx = firstInoutIndex {
            traceOutputExpression = "arg\(idx)"
        } else {
            traceOutputExpression = (returnType == .listNode || returnType == .treeNode) ? "result" : "output"
        }

        return SwiftInvocationPlan(
            callLine: callLine,
            outputExpression: outputExpression,
            traceOutputExpression: traceOutputExpression
        )
    }

    private static func buildSwiftWrapperSupport(
        code: String,
        typesUsed: [LeetCodeValueType]
    ) -> SwiftWrapperSupport {
        let needsListNode = typesUsed.contains { $0.needsListNode }
        let needsTreeNode = typesUsed.contains { $0.needsTreeNode }

        let needsListNodeSupport = needsListNode && !containsTypeDefinition(in: code, typeName: "ListNode")
        let needsTreeNodeSupport = needsTreeNode && !containsTypeDefinition(in: code, typeName: "TreeNode")

        let supportTypes = [
            needsListNodeSupport ? LeetCodeValueType.listNode : nil,
            needsTreeNodeSupport ? LeetCodeValueType.treeNode : nil
        ].compactMap { $0 }
        let supportClasses = supportTypes.isEmpty
            ? ""
            : LeetCodeTemplateBuilder.swiftSupportClasses(typesUsed: supportTypes)

        let listNodeHelpers: String
        if needsListNode {
            let listNodeInit = listNodeInitExpression(in: code, valueExpr: "toInt(item)", nextExpr: "nil")
            let listNodeZeroInit = listNodeInitExpression(in: code, valueExpr: "0", nextExpr: "nil")
            listNodeHelpers = swiftListNodeHelpers(
                listNodeInit: listNodeInit,
                listNodeZeroInit: listNodeZeroInit
            )
        } else {
            listNodeHelpers = ""
        }

        let treeNodeHelpers: String
        if needsTreeNode {
            let treeNodeInit = treeNodeInitExpression(
                in: code,
                valueExpr: "toInt(item)",
                leftExpr: "nil",
                rightExpr: "nil"
            )
            treeNodeHelpers = swiftTreeNodeHelpers(treeNodeInit: treeNodeInit)
        } else {
            treeNodeHelpers = ""
        }

        return SwiftWrapperSupport(
            supportClasses: supportClasses,
            listNodeHelpers: listNodeHelpers,
            treeNodeHelpers: treeNodeHelpers,
            needsListNode: needsListNode,
            needsTreeNode: needsTreeNode
        )
    }

	    private static func resolvedSwiftParams(
	        signature: SwiftFunctionSignature?,
	        meta: LeetCodeMetaData
    ) -> [LeetCodeMetaParam] {
        if let signature {
            return signature.params
        }
        let params = meta.primaryParams
        guard params.count > 1 else { return params }
        guard let last = params.last,
              last.name?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "pos" else {
            return params
        }
        let hasListNode = params.contains { LeetCodeValueType(raw: $0.type) == .listNode }
        let lastIsInt = LeetCodeValueType(raw: last.type) == .int
        if hasListNode && lastIsInt {
            return Array(params.dropLast())
        }
        return params
    }

    private static func swiftParamNamesLiteral(_ params: [LeetCodeMetaParam]) -> String {
        params.enumerated().map { index, param in
            let name = param.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let resolved = name.isEmpty ? "arg\(index + 1)" : name
            let escaped = resolved.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(escaped)\""
        }.joined(separator: ", ")
    }

    private static func swiftListNodeHelpers(listNodeInit: String, listNodeZeroInit: String) -> String {
        [
            swiftListNodeBuilder(listNodeInit: listNodeInit, listNodeZeroInit: listNodeZeroInit),
            swiftListNodePayloadHelper,
            swiftListNodeToArrayHelper,
            swiftTraceListNodePayloadHelper
        ].joined(separator: "\n\n")
    }

    private static func swiftListNodeBuilder(listNodeInit: String, listNodeZeroInit: String) -> String {
        """
        func toListNode(_ value: Any, pos: Int? = nil) -> ListNode? {
            let payload = listNodePayload(from: value)
            let array = payload.values
            guard !array.isEmpty else { return nil }
            let dummy = \(listNodeZeroInit)
            var current: ListNode? = dummy
            var tail: ListNode?
            var index = 0
            var cycleTarget: ListNode?
            let resolvedPos = pos ?? payload.pos
            for item in array {
                let node = \(listNodeInit)
                current?.next = node
                current = node
                tail = node
                if let resolvedPos, resolvedPos >= 0, index == resolvedPos {
                    cycleTarget = node
                }
                index += 1
            }
            if let cycleTarget {
                tail?.next = cycleTarget
            }
            return dummy.next
        }
        """
    }

    private static let swiftListNodePayloadHelper = """
        func listNodePayload(from value: Any) -> (values: [Any], pos: Int?) {
            if let dict = value as? [String: Any] {
                let head = dict["head"] ?? dict["list"] ?? dict["values"]
                let posValue = dict["pos"] ?? dict["index"]
                if let array = head as? [Any] {
                    return (array, posValue.map { toInt($0) })
                }
            }
            if let array = value as? [Any] {
                if array.count >= 2, let head = array[0] as? [Any] {
                    return (head, toInt(array[1]))
                }
                return (array, nil)
            }
            return ([], nil)
        }
        """

    private static let swiftListNodeToArrayHelper = """
        func listNodeToArray(_ node: ListNode?, maxNodes: Int = 10_000) -> [Int] {
            var result: [Int] = []
            var current = node
            var visited = Set<ObjectIdentifier>()
            var count = 0
            while let node = current, count < maxNodes {
                let id = ObjectIdentifier(node)
                if visited.contains(id) { break }
                visited.insert(id)
                result.append(node.val)
                current = node.next
                count += 1
            }
            return result
        }
        """

    private static let swiftTraceListNodePayloadHelper = """
        func listPointerPayload(_ node: ListNode?) -> Any {
            guard let node else { return NSNull() }
            return ["__type": "listPointer", "id": listNodeIdentifier(node)]
        }

        func listNodeIdentifier(_ node: ListNode) -> String {
            let ptr = Unmanaged.passUnretained(node).toOpaque()
            return String(UInt(bitPattern: ptr))
        }

        func traceListNodeStructure(_ node: ListNode?, maxNodes: Int = 40) -> (
            nodes: [Any],
            cycleIndex: Int?,
            truncated: Bool
        ) {
            guard let node else { return ([], nil, false) }
            var nodes: [Any] = []
            var current: ListNode? = node
            var visited: [ObjectIdentifier: Int] = [:]
            var index = 0
            while let currentNode = current, index < maxNodes {
                let id = ObjectIdentifier(currentNode)
                if let cycleAt = visited[id] {
                    return (nodes, cycleAt, false)
                }
                visited[id] = index
                let nodePayload: [String: Any] = [
                    "id": listNodeIdentifier(currentNode),
                    "value": currentNode.val
                ]
                nodes.append(nodePayload)
                current = currentNode.next
                index += 1
            }
            let truncated = current != nil
            return (nodes, nil, truncated)
        }
        """

    private static func swiftTreeNodeHelpers(treeNodeInit: String) -> String {
        [
            swiftTreeNodeBuilder(treeNodeInit: treeNodeInit),
            swiftTreeNodeToArrayHelper,
            swiftTraceTreePayloadHelper
        ].joined(separator: "\n\n")
    }

    private static func swiftTreeNodeBuilder(treeNodeInit: String) -> String {
        """
        func toTreeNode(_ value: Any) -> TreeNode? {
            guard let array = value as? [Any], !array.isEmpty else { return nil }
            var nodes: [TreeNode?] = array.map { item in
                if item is NSNull { return nil }
                return \(treeNodeInit)
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
        """
    }

    private static let swiftTreeNodeToArrayHelper = """
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
        """

    private static let swiftTraceTreePayloadHelper = """
        func treePointerPayload(_ node: TreeNode?) -> Any {
            guard let node else { return NSNull() }
            return ["__type": "treePointer", "id": treeNodeIdentifier(node)]
        }

        func treeNodeIdentifier(_ node: TreeNode) -> String {
            let ptr = Unmanaged.passUnretained(node).toOpaque()
            return String(UInt(bitPattern: ptr))
        }

        func traceTreeStructure(_ root: TreeNode?, maxNodes: Int = 40) -> (
            nodes: [Any],
            rootId: String?,
            truncated: Bool
        ) {
            guard let root else { return ([], nil, false) }
            var nodes: [Any] = []
            var queue: [TreeNode] = [root]
            var visited = Set<ObjectIdentifier>()
            var count = 0
            while !queue.isEmpty, count < maxNodes {
                let node = queue.removeFirst()
                let id = ObjectIdentifier(node)
                if visited.contains(id) { continue }
                visited.insert(id)
                var payload: [String: Any] = [
                    "id": treeNodeIdentifier(node),
                    "value": node.val
                ]
                if let left = node.left {
                    payload["left"] = treeNodeIdentifier(left)
                    queue.append(left)
                }
                if let right = node.right {
                    payload["right"] = treeNodeIdentifier(right)
                    queue.append(right)
                }
                nodes.append(payload)
                count += 1
            }
            let truncated = !queue.isEmpty
            return (nodes, treeNodeIdentifier(root), truncated)
        }
        """

    static func swiftConversionExpression(_ type: LeetCodeValueType, valueExpr: String) -> String {
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
        case .dictionary(let keyType, let valueType):
            let keyExpr = swiftConversionExpression(keyType, valueExpr: "key")
            let valueConv = swiftConversionExpression(valueType, valueExpr: "value")
            return "toDictionary(\(valueExpr), keyTransform: { key in \(keyExpr) }, valueTransform: { value in \(valueConv) })"
        case .listNode:
            return "toListNode(\(valueExpr))"
        case .treeNode:
            return "toTreeNode(\(valueExpr))"
        case .void, .unknown:
            return valueExpr
        }
    }

    static func swiftOutputExpression(for type: LeetCodeValueType) -> String {
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
}
