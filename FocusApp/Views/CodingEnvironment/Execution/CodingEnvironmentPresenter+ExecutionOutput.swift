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
}
