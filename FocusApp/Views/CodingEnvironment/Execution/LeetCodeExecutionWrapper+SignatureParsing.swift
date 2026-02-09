import Foundation

extension LeetCodeExecutionWrapper {
    struct SwiftFunctionSignature {
        let callName: String
        let params: [LeetCodeMetaParam]
        let returnType: String?
        /// External labels for each parameter. `nil` means `_` (no label needed at call site).
        let externalLabels: [String?]
        /// Whether the parameter is declared with `inout`.
        let inoutParams: [Bool]
    }

    private struct ParsedSwiftParams {
        let params: [LeetCodeMetaParam]
        let labels: [String?]
        let inoutFlags: [Bool]
    }

    static func swiftFunctionSignature(
        in code: String,
        className: String,
        methodName: String?
    ) -> SwiftFunctionSignature? {
        let container = typeDefinition(named: className, in: code)?.body
            ?? stripCommentsAndStrings(from: code)
        let signaturePattern =
            "func\\s+(`?[A-Za-z_][A-Za-z0-9_]*`?)\\s*\\(([^)]*)\\)\\s*"
            + "(?:->\\s*([^{\\n]+))?"
        guard let regex = try? NSRegularExpression(pattern: signaturePattern, options: []) else { return nil }
        let range = NSRange(location: 0, length: (container as NSString).length)
        let matches = regex.matches(in: container, options: [], range: range)
        guard !matches.isEmpty else { return nil }

        let targetName = methodName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeTarget = targetName.map {
            LeetCodeTemplateBuilder.swiftSafeIdentifier($0, index: 0)
                .replacingOccurrences(of: "`", with: "")
        }

        let signatures = matches.compactMap { match in
            parseSignatureMatch(match, in: container)
        }
        guard !signatures.isEmpty else { return nil }

        for (name, signature) in signatures {
            if let targetName, name == targetName || name == safeTarget {
                return signature
            }
        }

        if targetName == nil, let first = signatures.first {
            return first.1
        }
        return signatures.count == 1 ? signatures[0].1 : nil
    }

    private static func parseSignatureMatch(
        _ match: NSTextCheckingResult,
        in container: String
    ) -> (String, SwiftFunctionSignature)? {
        guard match.numberOfRanges >= 3 else { return nil }
        let nsContainer = container as NSString
        let rawName = nsContainer.substring(with: match.range(at: 1))
        let normalizedName = rawName.replacingOccurrences(of: "`", with: "")
        let paramsRaw = nsContainer.substring(with: match.range(at: 2))
        let returnRaw: String? = {
            guard match.numberOfRanges > 3 else { return nil }
            let range = match.range(at: 3)
            guard range.location != NSNotFound else { return nil }
            return nsContainer.substring(with: range)
        }()
        let parsed = parseSwiftParamsWithLabels(paramsRaw)
        let signature = SwiftFunctionSignature(
            callName: rawName,
            params: parsed.params,
            returnType: returnRaw?.trimmedNonEmpty,
            externalLabels: parsed.labels,
            inoutParams: parsed.inoutFlags
        )
        return (normalizedName, signature)
    }

    private static func parseSwiftParamsWithLabels(
        _ raw: String
    ) -> ParsedSwiftParams {
        let pieces = splitSwiftParameters(raw)
        var params: [LeetCodeMetaParam] = []
        var labels: [String?] = []
        var inoutFlags: [Bool] = []
        for piece in pieces {
            let trimmed = piece.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let parts = splitParameterDeclaration(trimmed)
            guard parts.count == 2 else { continue }
            let namePart = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
            var typePart = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !typePart.isEmpty else { continue }

            let nameTokens = namePart.split(whereSeparator: { $0.isWhitespace })
            let rawName = nameTokens.last.map(String.init) ?? ""
            let name = rawName == "_" || rawName.isEmpty ? nil : rawName

            // Extract external label: first token of nameTokens
            let externalLabel: String?
            if let first = nameTokens.first {
                let firstStr = String(first)
                externalLabel = firstStr == "_" ? nil : firstStr
            } else {
                externalLabel = nil
            }
            labels.append(externalLabel)

            let isInout = typePart.hasPrefix("inout ")
            if isInout {
                typePart = String(typePart.dropFirst("inout ".count))
            }
            let cleanedType = cleanTypeToken(typePart)
            params.append(LeetCodeMetaParam(name: name, type: cleanedType))
            inoutFlags.append(isInout)
        }
        return ParsedSwiftParams(params: params, labels: labels, inoutFlags: inoutFlags)
    }

    private static func splitSwiftParameters(_ raw: String) -> [String] {
        var results: [String] = []
        var current = ""
        var depth = 0
        for char in raw {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == "," && depth == 0 {
                results.append(current)
                current = ""
                continue
            }
            current.append(char)
        }
        if !current.isEmpty {
            results.append(current)
        }
        return results
    }

    private static func splitParameterDeclaration(_ raw: String) -> [String] {
        var depth = 0
        for (index, char) in raw.enumerated() {
            if char == "<" || char == "[" || char == "(" {
                depth += 1
            } else if char == ">" || char == "]" || char == ")" {
                depth = max(0, depth - 1)
            }
            if char == ":" && depth == 0 {
                let start = raw.startIndex
                let splitIndex = raw.index(start, offsetBy: index)
                let lhs = String(raw[..<splitIndex])
                let rhs = String(raw[raw.index(after: splitIndex)...])
                return [lhs, rhs]
            }
        }
        return []
    }

    private static func cleanTypeToken(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = trimmed.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
        var typePart = String(parts.first ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let qualifiers = ["@escaping", "@autoclosure"]
        for qualifier in qualifiers where typePart.hasPrefix(qualifier + " ") {
            typePart = typePart.replacingOccurrences(of: qualifier + " ", with: "")
        }
        return typePart
    }
}

extension String {
    fileprivate var trimmedNonEmpty: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
