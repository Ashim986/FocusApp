import Foundation

extension CodingEnvironmentPresenter {
    func setCode(_ newCode: String) {
        isApplyingExternalCode = true
        code = newCode
        isApplyingExternalCode = false
    }

    func handleCodeChange(oldValue: String) {
        guard !isApplyingExternalCode else { return }
        guard code != oldValue else { return }
        scheduleCodeSave()
    }

    func scheduleCodeSave() {
        guard let key = currentSolutionKey() else { return }
        let snapshot = code
        codeSaveTask?.cancel()
        codeSaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self?.interactor.saveSolution(code: snapshot, for: key)
            }
        }
    }

    func persistCurrentCode() {
        codeSaveTask?.cancel()
        guard let key = currentSolutionKey() else { return }
        interactor.saveSolution(code: code, for: key)
    }

    func currentSolutionKey() -> String? {
        guard let problem = selectedProblem else { return nil }
        return solutionKey(for: problem, language: language)
    }

    func solutionKey(for problem: Problem, language: ProgrammingLanguage) -> String {
        let base = LeetCodeSlugExtractor.extractSlug(from: problem.url) ?? problem.url
        return "\(base)|\(language.langSlug)"
    }

    func loadStoredCode(for problem: Problem, language: ProgrammingLanguage) -> String? {
        let key = solutionKey(for: problem, language: language)
        return interactor.solutionCode(for: key)
    }
}
