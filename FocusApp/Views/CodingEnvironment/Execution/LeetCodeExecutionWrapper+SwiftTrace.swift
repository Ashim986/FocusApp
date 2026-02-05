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
