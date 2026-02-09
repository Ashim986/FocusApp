import Foundation

// MARK: - Python Auto-Instrumentation

extension AutoInstrumenter {
    static func instrumentPython(
        code: String,
        entryPointName: String?,
        paramNames: [String]
    ) -> String {
        let hasManualTraceCalls = hasManualTrace(code: code, language: .python)

        let lines = code.components(separatedBy: "\n")
        var result: [String] = []
        let stripped = LeetCodeExecutionWrapper.stripCommentsAndStrings(from: code)
        let assignedVars = extractPythonAssignedVars(lines: lines)
        let resolvedEntryPointName = entryPointName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entryPoint = (resolvedEntryPointName?.isEmpty == false)
            ? resolvedEntryPointName
            : detectPythonEntryPointName(stripped: stripped)
        var entryParamNames = paramNames

        var solutionIndent: Int?
        var entryIndent: Int?
        var nestedDefIndents: [Int] = []

        for lineIndex in 0..<lines.count {
            let line = lines[lineIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let indentCount = leadingWhitespace(line).count

            if solutionIndent == nil,
               trimmed.range(of: "^class\\s+Solution\\b", options: .regularExpression) != nil {
                solutionIndent = indentCount
            }

            if let currentSolutionIndent = solutionIndent,
               indentCount <= currentSolutionIndent,
               trimmed.hasPrefix("class ") == false {
                // Left the Solution class.
                solutionIndent = nil
                entryIndent = nil
                nestedDefIndents = []
            }

            let isInSolution = solutionIndent.map { indentCount > $0 } ?? false
            if isInSolution,
               entryIndent == nil,
               let entryPoint,
               isPythonEntryPointSignature(trimmed: trimmed, name: entryPoint) {
                entryIndent = indentCount
                nestedDefIndents = []
                let parsedParams = pythonParamNamesFromSignature(trimmedSignatureLine: trimmed)
                if !parsedParams.isEmpty {
                    entryParamNames = parsedParams
                }
            }

            if let currentEntryIndent = entryIndent,
               indentCount <= currentEntryIndent,
               isInSolution,
               trimmed.hasPrefix("def ") == false {
                // Left the entry point method.
                entryIndent = nil
                nestedDefIndents = []
            }

            while let last = nestedDefIndents.last, indentCount <= last { nestedDefIndents.removeLast() }

            let isInEntryPoint = entryIndent.map { indentCount > $0 } ?? false
            if isInEntryPoint, trimmed.hasPrefix("def ") {
                nestedDefIndents.append(indentCount)
            }

            let canInstrument = isInEntryPoint && nestedDefIndents.isEmpty
            let captureDict = pythonCaptureExpression(
                paramNames: entryParamNames,
                assignedVars: assignedVars,
                loopVars: [],
                stripped: stripped
            )

            let lineWithReturnTrace = canInstrument
                ? injectPythonReturnTrace(into: line, captureDict: captureDict)
                : line
            result.append(lineWithReturnTrace)

            if canInstrument,
               hasManualTraceCalls == false,
               isPythonLoopOpening(trimmed: trimmed) {
                let bodyIndent = leadingWhitespace(line) + "    "
                let loopVars = extractPythonLoopVars(trimmed: trimmed)
                let loopCapture = pythonCaptureExpression(
                    paramNames: entryParamNames,
                    assignedVars: assignedVars,
                    loopVars: loopVars,
                    stripped: stripped
                )

                // Insert a try/except around trace so variable not-yet-defined errors
                // don't crash the program.
                let traceCall = "_Trace.step(\"loop\", \(loopCapture))"
                result.append(contentsOf: ["\(bodyIndent)try: \(traceCall)", "\(bodyIndent)except: pass"])
            }
        }

        return result.joined(separator: "\n")
    }
}

extension AutoInstrumenter {
    private static let commonPythonVars = [
        "result", "ans", "res", "output",
        "i", "j", "k", "idx", "index",
        "left", "right", "mid", "lo", "hi",
        "curr", "prev", "current", "next", "node", "head", "tail", "root", "dummy",
        "stack", "queue", "count", "total",
        "dp", "memo", "visited", "seen",
        "temp", "val", "key", "num",
        "fast", "slow", "first", "second", "pointer", "ptr"
    ]

    private static func pythonParamNamesFromSignature(trimmedSignatureLine: String) -> [String] {
        let pattern = "^def\\s+\\w+\\s*\\(([^)]*)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(trimmedSignatureLine.startIndex..., in: trimmedSignatureLine)
        guard let match = regex.firstMatch(in: trimmedSignatureLine, options: [], range: range),
              let argsRange = Range(match.range(at: 1), in: trimmedSignatureLine) else {
            return []
        }
        let argsRaw = String(trimmedSignatureLine[argsRange])
        let pieces = argsRaw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return pieces.compactMap { piece in
            let namePart = piece.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).first
            let name = namePart.map(String.init)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return nil }
            guard name != "self", name != "cls" else { return nil }
            return name
        }
    }

    private static func isPythonEntryPointSignature(trimmed: String, name: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        let pattern = "^def\\s+\(escaped)\\s*\\("
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private static func detectPythonEntryPointName(stripped: String) -> String? {
        let pattern = "^\\s*def\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\("
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else {
            return nil
        }
        let range = NSRange(stripped.startIndex..., in: stripped)
        guard let match = regex.firstMatch(in: stripped, options: [], range: range),
              let nameRange = Range(match.range(at: 1), in: stripped) else {
            return nil
        }
        return String(stripped[nameRange])
    }

    private static func injectPythonReturnTrace(into line: String, captureDict: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\breturn\\b") else { return line }
        let (codePart, commentPart) = splitPythonLineComment(line)
        let replacement = "_Trace.step(\"return\", \(captureDict)); return"
        let range = NSRange(codePart.startIndex..., in: codePart)
        let replaced = regex.stringByReplacingMatches(
            in: codePart,
            options: [],
            range: range,
            withTemplate: replacement
        )
        return replaced + commentPart
    }

    private static func splitPythonLineComment(_ line: String) -> (code: String, comment: String) {
        guard let range = line.range(of: "#") else { return (line, "") }
        return (String(line[..<range.lowerBound]), String(line[range.lowerBound...]))
    }

    private static func isPythonLoopOpening(trimmed: String) -> Bool {
        let loopPatterns = [
            "^for\\s+.*:\\s*$",
            "^while\\s+.*:\\s*$"
        ]
        return loopPatterns.contains { trimmed.range(of: $0, options: .regularExpression) != nil }
    }

    private static func pythonCaptureExpression(
        paramNames: [String],
        assignedVars: [String],
        loopVars: [String],
        stripped: String
    ) -> String {
        let presentCommonVars = commonPythonVars.filter { name in
            variableExistsInCode(name: name, stripped: stripped)
        }
        let allVars = (paramNames + loopVars + assignedVars + presentCommonVars)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { isValidPythonIdentifier($0) && !$0.hasPrefix("_") && $0 != "self" && $0 != "cls" }
            .uniqued()
        let pairs = allVars.prefix(24).map { name in
            "\"\(name)\": (locals().get(\"\(name)\") if \"\(name)\" in locals() else globals().get(\"\(name)\"))"
        }
        return "{\(pairs.joined(separator: ", "))}"
    }

    private static func variableExistsInCode(name: String, stripped: String) -> Bool {
        // Word-boundary check so "i" doesn't match inside "if" or "while".
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: name))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        return regex.firstMatch(
            in: stripped,
            range: NSRange(stripped.startIndex..., in: stripped)
        ) != nil
    }

    private static func extractPythonAssignedVars(lines: [String]) -> [String] {
        let assignmentPattern =
            "^([a-zA-Z_][a-zA-Z0-9_]*(?:\\s*,\\s*[a-zA-Z_][a-zA-Z0-9_]*)*)\\s*" +
            "(?:=|\\+=|-=|\\*=|/=|//=|%=|\\|=|&=|\\^=)"
        let annotatedAssignmentPattern = "^([a-zA-Z_][a-zA-Z0-9_]*)\\s*:[^=]+="
        guard let assignmentRegex = try? NSRegularExpression(pattern: assignmentPattern),
              let annotatedRegex = try? NSRegularExpression(pattern: annotatedAssignmentPattern) else {
            return []
        }

        var names: [String] = []
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.hasPrefix("#") else { continue }

            if let match = assignmentRegex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
            ),
            let range = Range(match.range(at: 1), in: trimmed) {
                let lhs = String(trimmed[range])
                names.append(contentsOf: lhs
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                )
            } else if let match = annotatedRegex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
            ),
            let range = Range(match.range(at: 1), in: trimmed) {
                names.append(String(trimmed[range]))
            }

            names.append(contentsOf: extractPythonLoopVars(trimmed: trimmed))
        }

        return names
            .filter { isValidPythonIdentifier($0) && !$0.hasPrefix("_") && $0 != "self" && $0 != "cls" }
            .uniqued()
    }

    private static func extractPythonLoopVars(trimmed: String) -> [String] {
        let pattern = "^for\\s+(.+?)\\s+in\\s+"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: trimmed,
                range: NSRange(trimmed.startIndex..., in: trimmed)
              ),
              let bindingRange = Range(match.range(at: 1), in: trimmed) else {
            return []
        }
        let binding = String(trimmed[bindingRange])
        let identPattern = "\\b([a-zA-Z_]\\w*)\\b"
        guard let identRegex = try? NSRegularExpression(pattern: identPattern) else {
            return []
        }
        let matches = identRegex.matches(
            in: binding,
            range: NSRange(binding.startIndex..., in: binding)
        )
        let skip: Set<String> = ["_"]
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: binding) else { return nil }
            let name = String(binding[range])
            if skip.contains(name) { return nil }
            return name
        }
    }

    private static func isValidPythonIdentifier(_ name: String) -> Bool {
        guard !name.isEmpty else { return false }
        let pattern = "^[a-zA-Z_][a-zA-Z0-9_]*$"
        return name.range(of: pattern, options: .regularExpression) != nil
    }
}
