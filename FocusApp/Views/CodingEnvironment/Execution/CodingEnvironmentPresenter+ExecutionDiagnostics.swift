import Foundation

extension CodingEnvironmentPresenter {
    func extractDiagnostics(
        from errorOutput: String,
        language: ProgrammingLanguage,
        code: String
    ) -> [CodeEditorDiagnostic] {
        guard !errorOutput.isEmpty else { return [] }
        let codeLineCount = max(
            code.split(separator: "\n", omittingEmptySubsequences: false).count,
            1
        )
        var collector = DiagnosticCollector(codeLineCount: codeLineCount)

        switch language {
        case .swift:
            parseSwiftDiagnostics(errorOutput, collector: &collector)
        case .python:
            parsePythonDiagnostics(errorOutput, collector: &collector)
        }

        if collector.results.isEmpty {
            addFallbackDiagnostics(from: errorOutput, collector: &collector)
        }

        return collector.results
    }

    private func parseSwiftDiagnostics(_ errorOutput: String, collector: inout DiagnosticCollector) {
        let pattern = "([^\\s:]+\\.swift):(\\d+):(\\d+):\\s*(?:error|warning):\\s*(.+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        let range = NSRange(location: 0, length: (errorOutput as NSString).length)
        for match in regex.matches(in: errorOutput, range: range) {
            guard match.numberOfRanges >= 5 else { continue }
            let lineString = (errorOutput as NSString).substring(with: match.range(at: 2))
            let columnString = (errorOutput as NSString).substring(with: match.range(at: 3))
            let message = (errorOutput as NSString).substring(with: match.range(at: 4))
            guard let line = Int(lineString) else { continue }
            let column = Int(columnString)
            collector.add(line: line, column: column, message: message, offset: 0)
        }
    }

    private func parsePythonDiagnostics(_ errorOutput: String, collector: inout DiagnosticCollector) {
        let lines = errorOutput.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        let fallbackMessage = extractPythonFallbackMessage(from: lines)

        guard let fileRegex = try? NSRegularExpression(
            pattern: "File \\\"([^\\\"]+)\\\", line (\\d+)",
            options: []
        ) else {
            return
        }

        for index in lines.indices {
            let line = String(lines[index])
            let lineRange = NSRange(location: 0, length: (line as NSString).length)
            guard let match = fileRegex.firstMatch(in: line, range: lineRange),
                  match.numberOfRanges >= 3 else { continue }
            let lineString = (line as NSString).substring(with: match.range(at: 2))
            guard let lineNumber = Int(lineString) else { continue }

            let (column, message) = parsePythonCaret(at: index, lines: lines)
            let finalMessage = message ?? fallbackMessage ?? "Error"
            collector.add(line: lineNumber, column: column, message: finalMessage, offset: 0)
        }
    }

    private func extractPythonFallbackMessage(from lines: [Substring]) -> String? {
        for line in lines.reversed() {
            let trimmed = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            if trimmed.contains("Error") || trimmed.contains("Exception") {
                return trimmed
            }
        }
        return nil
    }

    private func parsePythonCaret(at index: Int, lines: [Substring]) -> (Int?, String?) {
        guard index + 2 < lines.count else { return (nil, nil) }
        let caretLine = String(lines[index + 2])
        guard let caretIndex = caretLine.firstIndex(of: "^") else { return (nil, nil) }
        let column = caretLine.distance(from: caretLine.startIndex, to: caretIndex) + 1

        guard index + 3 < lines.count else { return (column, nil) }
        let candidate = String(lines[index + 3]).trimmingCharacters(in: .whitespacesAndNewlines)
        return (column, candidate.isEmpty ? nil : candidate)
    }

    private func addFallbackDiagnostics(from errorOutput: String, collector: inout DiagnosticCollector) {
        let fallbackPattern = "(?:^|\\n)\\s*(\\d+)\\s*\\|"
        guard let regex = try? NSRegularExpression(pattern: fallbackPattern, options: []) else { return }
        let range = NSRange(location: 0, length: (errorOutput as NSString).length)
        for match in regex.matches(in: errorOutput, range: range) {
            guard match.numberOfRanges >= 2 else { continue }
            let lineString = (errorOutput as NSString).substring(with: match.range(at: 1))
            if let line = Int(lineString) {
                collector.add(line: line, column: nil, message: "Error", offset: 0)
            }
        }
    }

    private struct DiagnosticCollector {
        let codeLineCount: Int
        var results: [CodeEditorDiagnostic] = []
        var seen: Set<CodeEditorDiagnostic> = []

        mutating func add(line: Int, column: Int?, message: String, offset: Int) {
            let userLine = line - offset
            guard userLine >= 1 else { return }
            let clampedLine = min(userLine, codeLineCount)
            let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
            let finalMessage = trimmedMessage.isEmpty ? "Error" : trimmedMessage
            let diagnostic = CodeEditorDiagnostic(line: clampedLine, column: column, message: finalMessage)
            if seen.insert(diagnostic).inserted {
                results.append(diagnostic)
            }
        }
    }
}
