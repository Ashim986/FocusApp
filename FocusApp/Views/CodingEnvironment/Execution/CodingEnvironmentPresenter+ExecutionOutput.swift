import Foundation

extension CodingEnvironmentPresenter {
    struct NormalizedOutput {
        /// Full raw output for display to the user (trimmed whitespace only).
        let displayValue: String
        /// Extracted comparison value used for pass/fail matching against expected output.
        let comparisonValue: String
    }

    func normalizeOutputForComparison(_ output: String, expected: String) -> NormalizedOutput {
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedExpected.isEmpty {
            return NormalizedOutput(displayValue: trimmedOutput, comparisonValue: trimmedOutput)
        }

        if trimmedOutput == trimmedExpected {
            return NormalizedOutput(displayValue: trimmedOutput, comparisonValue: trimmedOutput)
        }

        if trimmedOutput.hasSuffix(trimmedExpected) {
            return NormalizedOutput(displayValue: trimmedOutput, comparisonValue: trimmedExpected)
        }

        if !trimmedExpected.contains("\n") {
            let lastLine = trimmedOutput.split(whereSeparator: \.isNewline).last
            let comparison = lastLine.map(String.init) ?? trimmedOutput
            return NormalizedOutput(displayValue: trimmedOutput, comparisonValue: comparison)
        }

        return NormalizedOutput(displayValue: trimmedOutput, comparisonValue: trimmedOutput)
    }

    /// Compares actual vs expected output.
    /// - Parameter orderMatters: When `true`, requires exact string match.
    ///   When `false`, allows order-insensitive matching for flat JSON arrays
    ///   (e.g. `[1,2]` matches `[2,1]` for "return in any order" problems).
    func outputMatches(
        _ actual: String,
        expected: String,
        orderMatters: Bool = true
    ) -> Bool {
        if actual == expected { return true }

        let normActual = Self.stripSurroundingQuotes(actual)
        let normExpected = Self.stripSurroundingQuotes(expected)
        if normActual == normExpected { return true }

        let compactActual = Self.compactJSON(normActual)
        let compactExpected = Self.compactJSON(normExpected)
        if compactActual == compactExpected { return true }

        // Only try order-insensitive comparison when the problem allows any order
        guard !orderMatters else { return false }
        if let sortedActual = sortedJSONArray(compactActual),
           let sortedExpected = sortedJSONArray(compactExpected) {
            return sortedActual == sortedExpected
        }
        return false
    }

    private static func stripSurroundingQuotes(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2, trimmed.hasPrefix("\""), trimmed.hasSuffix("\"") {
            let inner = String(trimmed.dropFirst().dropLast())
            if !inner.contains("\"") { return inner }
        }
        return trimmed
    }

    private static func compactJSON(_ value: String) -> String {
        var result = value
        result = result.replacingOccurrences(of: ", ", with: ",")
        result = result.replacingOccurrences(of: ": ", with: ":")
        return result
    }

    /// Parses a JSON array string and returns a sorted string representation.
    /// Returns nil if the string is not a valid flat JSON array.
    private func sortedJSONArray(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("["), trimmed.hasSuffix("]"),
              let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let array = json as? [Any] else {
            return nil
        }
        // Only sort flat arrays (no nested arrays/objects)
        let strings = array.map { element -> String in
            if let num = element as? NSNumber {
                if CFNumberIsFloatType(num as CFNumber) {
                    return String(num.doubleValue)
                }
                return String(num.intValue)
            }
            if let str = element as? String {
                return "\"\(str)\""
            }
            return String(describing: element)
        }
        return "[" + strings.sorted().joined(separator: ",") + "]"
    }
}
