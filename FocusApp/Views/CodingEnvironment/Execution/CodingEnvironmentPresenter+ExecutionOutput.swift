import Foundation

extension CodingEnvironmentPresenter {
    func normalizeOutputForComparison(_ output: String, expected: String) -> String {
        let trimmedOutput = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedExpected.isEmpty {
            return trimmedOutput
        }

        if trimmedOutput == trimmedExpected {
            return trimmedOutput
        }

        if trimmedOutput.hasSuffix(trimmedExpected) {
            return trimmedExpected
        }

        if !trimmedExpected.contains("\n") {
            let lastLine = trimmedOutput.split(whereSeparator: \.isNewline).last
            return lastLine.map(String.init) ?? trimmedOutput
        }

        return trimmedOutput
    }
}
