import Foundation

extension LeetCodeExecutionWrapper {
    static func swiftRunnerTrace(needsListNode: Bool, needsTreeNode: Bool) -> String {
        var traceValueLines: [String] = swiftRunnerTraceBaseLines

        if needsListNode {
            traceValueLines.append(
                "                if let node = value as? ListNode { return [\"__type\": \"list\", \"value\": "
                    + "listNodeToArray(node)] }"
            )
        }
        if needsTreeNode {
            traceValueLines.append(
                "                if let node = value as? TreeNode { return [\"__type\": \"tree\", \"value\": "
                    + "treeNodeToArray(node)] }"
            )
        }

        traceValueLines.append(contentsOf: swiftRunnerTraceTailLines)

        let traceValueBody = traceValueLines.joined(separator: "\n")

        return swiftRunnerTraceTemplateStart + traceValueBody + swiftRunnerTraceTemplateEnd
    }

    private static let swiftRunnerTraceBaseLines: [String] = [
        "                let mirror = Mirror(reflecting: value)",
        "                if mirror.displayStyle == .optional {",
        "                    if let child = mirror.children.first {",
        "                        return traceValue(child.value)",
        "                    }",
        "                    return NSNull()",
        "                }",
        "                if value is NSNull { return NSNull() }",
        "                if let numberValue = value as? NSNumber {",
        "                    if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {",
        "                        return numberValue.boolValue",
        "                    }",
        "                    return numberValue",
        "                }",
        "                if let boolValue = value as? Bool { return boolValue }"
    ]

    private static let swiftRunnerTraceTailLines: [String] = [
        "                if let array = value as? [Any] {",
        "                    return array.map { traceValue($0) }",
        "                }",
        "                if let dict = value as? [String: Any] {",
        "                    var mapped: [String: Any] = [:]",
        "                    for (key, val) in dict {",
        "                        mapped[key] = traceValue(val)",
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
                emit(kind: "step", line: line, label: label, values: values)
            }

            static func input(paramNames: [String], args: [Any]) {
                guard !args.isEmpty else { return }
                var values: [String: Any?] = [:]
                for (index, name) in paramNames.enumerated() {
                    let value = index < args.count ? args[index] : NSNull()
                    values[name] = traceValue(value)
                }
                emit(kind: "input", values: values)
            }

            static func output(_ value: Any) {
                emit(kind: "output", values: ["result": traceValue(value)])
            }

            private static func traceValue(_ value: Any) -> Any {
        """

    private static let swiftRunnerTraceTemplateEnd = """

            }

            private static func emit(kind: String, line: Int? = nil, label: String? = nil, values: [String: Any?]) {
                var mapped: [String: Any] = [:]
                for (key, val) in values {
                    if let val {
                        mapped[key] = traceValue(val)
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
