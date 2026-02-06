import Foundation

extension LeetCodeExecutionWrapper {
    static func swiftRunnerPrelude(paramNamesLiteral: String) -> String {
        swiftRunnerPreludeHeader(paramNamesLiteral: paramNamesLiteral) + swiftRunnerPreludeBody
    }

    private static func swiftRunnerPreludeHeader(paramNamesLiteral: String) -> String {
        """
        // FocusApp LeetCode Runner
        let paramNames = [\(paramNamesLiteral)]

        """
    }

    private static let swiftRunnerPreludeBody = #"""
        func parseQuotedString(_ input: String) -> String? {
            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 2,
                  trimmed.first == "\"",
                  trimmed.last == "\"" else { return nil }
            let inner = String(trimmed.dropFirst().dropLast())
            var result = ""
            var isEscaping = false
            for char in inner {
                if isEscaping {
                    switch char {
                    case "n":
                        result.append("\n")
                    case "r":
                        result.append("\r")
                    case "t":
                        result.append("\t")
                    case "\"":
                        result.append("\"")
                    case "\\":
                        result.append("\\")
                    default:
                        result.append(char)
                    }
                    isEscaping = false
                } else if char == "\\" {
                    isEscaping = true
                } else {
                    result.append(char)
                }
            }
            if isEscaping {
                result.append("\\")
            }
            return result
        }

        func normalizeStringValue(_ value: Any) -> Any {
            if let stringValue = value as? String,
               let quoted = parseQuotedString(stringValue) {
                return quoted
            }
            return value
        }

        func normalizeStringValues(_ values: [Any]) -> [Any] {
            values.map { normalizeStringValue($0) }
        }

        func parseKeyValueInput(_ input: String, paramNames: [String]) -> [String: Any] {
            guard !paramNames.isEmpty else { return [:] }
            let pattern = "\\b([A-Za-z_][A-Za-z0-9_]*)\\b\\s*="
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
                    results[name] = normalizeStringValue(json)
                } else if let quoted = parseQuotedString(cleaned) {
                    results[name] = quoted
                } else {
                    results[name] = normalizeStringValue(cleaned)
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
            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return [] }
            let keyValues = parseKeyValueInput(trimmed, paramNames: paramNames)
            if !keyValues.isEmpty {
                let ordered = paramNames.compactMap { keyValues[$0] }
                return normalizeStringValues(ordered)
            }
            if let data = trimmed.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) {
                if expectedCount == 1 {
                    return [normalizeStringValue(json)]
                }
                if let array = json as? [Any] { return normalizeStringValues(array) }
                return [normalizeStringValue(json)]
            }
            if let quoted = parseQuotedString(trimmed) {
                return [quoted]
            }
            let lines = trimmed.split(whereSeparator: { $0.isNewline }).map(String.init)
            var values: [Any] = []
            for line in lines {
                if let data = line.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) {
                    values.append(normalizeStringValue(json))
                } else if let quoted = parseQuotedString(line) {
                    values.append(quoted)
                } else {
                    values.append(normalizeStringValue(line))
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

        func parseCyclePos(from input: String) -> Int? {
            let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            let keyPattern = "\\bpos\\b\\s*=\\s*([^,\\n\\r]+)"
            if let regex = try? NSRegularExpression(pattern: keyPattern, options: []) {
                let nsInput = trimmed as NSString
                let searchRange = NSRange(location: 0, length: nsInput.length)
                if let match = regex.firstMatch(in: trimmed, options: [], range: searchRange),
                   match.numberOfRanges >= 2 {
                    let rawValue = nsInput.substring(with: match.range(at: 1))
                    let cleaned = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let data = cleaned.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) {
                        return toInt(json)
                    }
                    if let intValue = Int(cleaned) { return intValue }
                }
            }

            let lines = trimmed.split(whereSeparator: { $0.isNewline }).map(String.init)
            if lines.count >= 2 {
                let first = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let second = lines[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if first.hasPrefix("[") {
                    if let data = second.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) {
                        return toInt(json)
                    }
                    if let intValue = Int(second) { return intValue }
                }
            }

            if let data = trimmed.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data),
               let array = json as? [Any],
               array.count >= 2,
               array[0] is [Any] {
                return toInt(array[1])
            }

            return nil
        }

        func valueAt(_ args: [Any], _ index: Int) -> Any {
            guard args.indices.contains(index) else { return NSNull() }
            return args[index]
        }
        """#

    static func swiftRunnerConversions(listNodeHelpers: String, treeNodeHelpers: String) -> String {
        """

        func toInt(_ value: Any) -> Int {
            if let intValue = value as? Int { return intValue }
            if let doubleValue = value as? Double { return Int(doubleValue) }
            if let stringValue = value as? String,
                let intValue = Int(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return intValue
            }
            return 0
        }

        func toDouble(_ value: Any) -> Double {
            if let doubleValue = value as? Double { return doubleValue }
            if let intValue = value as? Int { return Double(intValue) }
            if let stringValue = value as? String,
                let doubleValue = Double(stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
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
            if let stringValue = value as? String,
               let quoted = parseQuotedString(stringValue) {
                return quoted
            }
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

        func toDictionary<K: Hashable, V>(
            _ value: Any,
            keyTransform: (Any) -> K,
            valueTransform: (Any) -> V
        ) -> [K: V] {
            if let dict = value as? [String: Any] {
                var result: [K: V] = [:]
                for (key, val) in dict {
                    result[keyTransform(key)] = valueTransform(val)
                }
                return result
            }
            if let dict = value as? [AnyHashable: Any] {
                var result: [K: V] = [:]
                for (key, val) in dict {
                    result[keyTransform(key)] = valueTransform(val)
                }
                return result
            }
            return [:]
        }
        \(listNodeHelpers)
        \(treeNodeHelpers)
        """
    }

    static func swiftRunnerMain(
        paramsCount: Int,
        arguments: [String],
        callLine: String,
        outputExpression: String,
        traceOutputExpression: String,
        setupLines: [String] = []
    ) -> String {
        let argumentsString = arguments.joined(separator: "\n")
        let setupString = setupLines.joined(separator: "\n")
        let traceArgsList = (0..<paramsCount).map { "arg\($0) as Any" }.joined(separator: ", ")
        let traceInput = paramsCount == 0
            ? ""
            : """
            let traceArgs: [Any] = [\(traceArgsList)]
            if hasInput {
                Trace.input(paramNames: paramNames, args: traceArgs)
            }
            """
        return """

        let inputData = FileHandle.standardInput.readDataToEndOfFile()
        let input = String(data: inputData, encoding: .utf8) ?? ""
        let args = parseArgs(from: input, expectedCount: \(paramsCount))
        let hasInput = !args.isEmpty
        let solution = Solution()
        \(setupString)
        \(argumentsString)
        \(traceInput)
        \(callLine)
        let output: Any = \(outputExpression)
        if hasInput {
            Trace.output(\(traceOutputExpression))
        }
        print(jsonString(from: output))
        """
    }
}
