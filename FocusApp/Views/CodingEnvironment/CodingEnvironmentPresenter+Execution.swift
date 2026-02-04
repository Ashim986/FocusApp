import Foundation

extension CodingEnvironmentPresenter {
    func runCode() {
        guard !isRunning else { return }
        isRunning = true
        compilationOutput = ""
        errorOutput = ""

        runTask?.cancel()
        runTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.runTask = nil
                }
            }
            let executionCode = self.wrappedCodeForExecution()
            let runInput = testCases.first?.input ?? ""
            let result = await interactor.executeCode(
                code: executionCode,
                language: language,
                input: runInput
            )

            guard !Task.isCancelled else { return }
            await MainActor.run {
                if result.wasCancelled {
                    self.errorOutput = "Execution stopped by user."
                } else if result.timedOut {
                    self.errorOutput = "Execution timed out (10 second limit)"
                } else if !result.error.isEmpty {
                    self.errorOutput = result.error
                } else {
                    self.compilationOutput = result.output
                }
                self.isRunning = false
            }
        }
    }

    func runTests() {
        guard !isRunning, !testCases.isEmpty else { return }
        isRunning = true
        compilationOutput = ""
        errorOutput = ""

        runTask?.cancel()
        runTask = Task { [weak self] in
            guard let self else { return }
            defer {
                Task { @MainActor in
                    self.runTask = nil
                }
            }
            var updatedTestCases = testCases
            var consoleLogs: [String] = []
            var errorLogs: [String] = []
            let executionCode = self.wrappedCodeForExecution()

            for i in updatedTestCases.indices {
                if Task.isCancelled { break }
                let testCase = updatedTestCases[i]
                let result = await interactor.executeCode(
                    code: executionCode,
                    language: language,
                    input: testCase.input
                )

                if Task.isCancelled { break }
                await MainActor.run {
                    if result.wasCancelled {
                        updatedTestCases[i].actualOutput = "Stopped"
                        updatedTestCases[i].passed = false
                    } else if result.timedOut {
                        updatedTestCases[i].actualOutput = "Timed out"
                        updatedTestCases[i].passed = false
                    } else if !result.error.isEmpty {
                        updatedTestCases[i].actualOutput = "Error: \(result.error)"
                        updatedTestCases[i].passed = false
                    } else {
                        let normalizedExpected = testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                        let normalizedActual = self.normalizeOutputForComparison(result.output, expected: normalizedExpected)
                        updatedTestCases[i].actualOutput = normalizedActual
                        updatedTestCases[i].passed = normalizedActual == normalizedExpected
                    }
                    self.testCases = updatedTestCases
                }

                if !result.output.isEmpty {
                    consoleLogs.append("Test \(i + 1):\n\(result.output)")
                }

                if !result.error.isEmpty {
                    errorLogs.append("Test \(i + 1):\n\(result.error)")
                }
            }

            guard !Task.isCancelled else { return }
            await MainActor.run {
                if !consoleLogs.isEmpty {
                    self.compilationOutput = consoleLogs.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
                }

                if !errorLogs.isEmpty {
                    self.errorOutput = errorLogs.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                self.isRunning = false
            }
        }
    }

    func stopExecution() {
        guard isRunning else { return }
        runTask?.cancel()
        interactor.cancelExecution()
        runTask = nil
        isRunning = false
        errorOutput = "Execution stopped by user."
    }

    private func wrappedCodeForExecution() -> String {
        guard let meta = LeetCodeMetaData.decode(from: problemContent?.metaData) else { return code }
        return LeetCodeExecutionWrapper.wrap(code: code, language: language, meta: meta)
    }

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
