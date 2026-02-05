import Foundation

extension LeetCodeExecutionWrapper {
    static func swiftRunnerTrace(needsListNode: Bool, needsTreeNode: Bool) -> String {
        var traceValueLines: [String] = swiftRunnerTraceBaseLines

        if needsListNode {
            traceValueLines.append(contentsOf: [
                "                if let node = value as? ListNode {",
                "                    if structured {",
                "                        let payload = traceListNodeStructure(node)",
                "                        var result: [String: Any] = [\"__type\": \"list\", \"nodes\": payload.nodes]",
                "                        if let cycleIndex = payload.cycleIndex {",
                "                            result[\"cycleIndex\"] = cycleIndex",
                "                        }",
                "                        if payload.truncated { result[\"truncated\"] = true }",
                "                        return result",
                "                    }",
                "                    return listPointerPayload(node)",
                "                }"
            ])
        }
        if needsTreeNode {
            traceValueLines.append(contentsOf: [
                "                if let node = value as? TreeNode {",
                "                    if structured {",
                "                        let payload = traceTreeStructure(node)",
                "                        var result: [String: Any] = [\"__type\": \"tree\", \"nodes\": payload.nodes]",
                "                        if let rootId = payload.rootId {",
                "                            result[\"rootId\"] = rootId",
                "                        }",
                "                        if payload.truncated { result[\"truncated\"] = true }",
                "                        return result",
                "                    }",
                "                    return treePointerPayload(node)",
                "                }"
            ])
        }

        traceValueLines.append(contentsOf: swiftRunnerDoublyListLines)

        traceValueLines.append(contentsOf: swiftRunnerTraceTailLines)

        let traceValueBody = traceValueLines.joined(separator: "\n")

        return swiftRunnerTraceTemplateStart + traceValueBody + swiftRunnerTraceTemplateEnd
    }

    private static let swiftRunnerTraceBaseLines: [String] = [
        "                let mirror = Mirror(reflecting: value)",
        "                if mirror.displayStyle == .optional {",
        "                    if let child = mirror.children.first {",
        "                        return traceValue(child.value, structured: structured)",
        "                    }",
        "                    return NSNull()",
        "                }",
        "                if value is NSNull { return NSNull() }",
        "                if let numberValue = value as? NSNumber {",
        "                    let objCType = String(cString: numberValue.objCType)",
        "                    if objCType == \"c\" || objCType == \"B\" {",
        "                        return numberValue.boolValue",
        "                    }",
        "                    return numberValue",
        "                }",
        "                if let boolValue = value as? Bool { return boolValue }"
    ]

    private static let swiftRunnerTraceTailLines: [String] = [
        "                if let array = value as? [Any] {",
        "                    return array.map { traceValue($0, structured: structured) }",
        "                }",
        "                if let dict = value as? [String: Any] {",
        "                    var mapped: [String: Any] = [:]",
        "                    for (key, val) in dict {",
        "                        mapped[key] = traceValue(val, structured: structured)",
        "                    }",
        "                    return mapped",
        "                }",
        "                if let stringValue = value as? String { return stringValue }",
        "                return String(describing: value)"
    ]

    private static let swiftRunnerDoublyListLines: [String] = [
        "                if isDoublyListNode(value) {",
        "                    if structured {",
        "                        let payload = traceDoublyListStructure(value)",
        "                        var result: [String: Any] = [\"__type\": \"doublyList\", \"nodes\": payload.nodes]",
        "                        if let cycleIndex = payload.cycleIndex {",
        "                            result[\"cycleIndex\"] = cycleIndex",
        "                        }",
        "                        if payload.truncated { result[\"truncated\"] = true }",
        "                        return result",
        "                    }",
        "                    return doublyListPointerPayload(value)",
        "                }"
    ]

    private static let swiftRunnerTraceTemplateStart = """

        struct Trace {
            private static let prefix = "__focus_trace__"

            static func step(_ label: String, _ values: [String: Any?] = [:], line: Int = #line) {
                emit(kind: "step", line: line, label: label, values: values, structured: false)
            }

            static func input(paramNames: [String], args: [Any]) {
                guard !args.isEmpty else { return }
                var values: [String: Any?] = [:]
                for (index, name) in paramNames.enumerated() {
                    let value = index < args.count ? args[index] : NSNull()
                    values[name] = traceValue(value, structured: true)
                }
                emit(kind: "input", values: values, structured: true)
            }

            static func output(_ value: Any) {
                emit(kind: "output", values: ["result": traceValue(value, structured: true)], structured: true)
            }

            private static func traceValue(_ value: Any, structured: Bool) -> Any {
        """

    private static let swiftRunnerTraceTemplateEnd = """

            }

            private static func emit(
                kind: String,
                line: Int? = nil,
                label: String? = nil,
                values: [String: Any?],
                structured: Bool
            ) {
                var mapped: [String: Any] = [:]
                for (key, val) in values {
                    if let val {
                        mapped[key] = traceValue(val, structured: structured)
                    } else {
                        mapped[key] = NSNull()
                    }
                }
                var payload: [String: Any] = [
                    "kind": kind,
                    "values": mapped
                ]
                if let line { payload["line"] = line }
                if let label { payload["label"] = label }
                guard JSONSerialization.isValidJSONObject(payload),
                      let data = try? JSONSerialization.data(withJSONObject: payload),
                      let json = String(data: data, encoding: .utf8) else { return }
                print(prefix + json)
            }

            private static func isDoublyListNode(_ value: Any) -> Bool {
                let mirror = Mirror(reflecting: value)
                guard mirror.displayStyle == .class else { return false }
                let labels = Set(mirror.children.compactMap { $0.label })
                let hasPrev = labels.contains("prev")
                let hasNext = labels.contains("next")
                let hasVal = labels.contains("val") || labels.contains("value")
                return hasPrev && hasNext && hasVal
            }

            private static func doublyListPointerPayload(_ value: Any) -> Any {
                guard let object = value as AnyObject? else { return NSNull() }
                return ["__type": "listPointer", "id": doublyListIdentifier(object)]
            }

            private static func doublyListIdentifier(_ object: AnyObject) -> String {
                String(ObjectIdentifier(object).hashValue)
            }

            private static func traceDoublyListStructure(_ value: Any, maxNodes: Int = 40) -> (
                nodes: [Any],
                cycleIndex: Int?,
                truncated: Bool
            ) {
                guard let start = value as AnyObject? else { return ([], nil, false) }
                var nodes: [Any] = []
                var current: Any? = start
                var visited: [ObjectIdentifier: Int] = [:]
                var index = 0
                while let currentValue = current, index < maxNodes {
                    guard let currentObject = currentValue as AnyObject? else { break }
                    let id = ObjectIdentifier(currentObject)
                    if let cycleAt = visited[id] {
                        return (nodes, cycleAt, false)
                    }
                    visited[id] = index
                    let val = childValue(in: currentValue, names: ["val", "value"]) ?? NSNull()
                    let payload: [String: Any] = [
                        "id": doublyListIdentifier(currentObject),
                        "value": traceValue(val, structured: true)
                    ]
                    nodes.append(payload)
                    let nextValue = childValue(in: currentValue, names: ["next"]).flatMap { unwrapOptional($0) }
                    current = nextValue
                    index += 1
                }
                let truncated = current != nil
                return (nodes, nil, truncated)
            }

            private static func childValue(in value: Any, names: [String]) -> Any? {
                let mirror = Mirror(reflecting: value)
                for child in mirror.children {
                    guard let label = child.label else { continue }
                    if names.contains(label) { return child.value }
                }
                return nil
            }

            private static func unwrapOptional(_ value: Any) -> Any? {
                let mirror = Mirror(reflecting: value)
                guard mirror.displayStyle == .optional else { return value }
                return mirror.children.first?.value
            }
        }

        func jsonString(from value: Any) -> String {
            let mirror = Mirror(reflecting: value)
            if mirror.displayStyle == .optional {
                if let child = mirror.children.first {
                    return jsonString(from: child.value)
                }
                return "null"
            }
            if value is NSNull { return "null" }
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
        """
}
