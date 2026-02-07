import Foundation

@MainActor
struct CodingEnvironmentFlow {
    let app: CodingEnvironmentApp

    func openProblem(slug: String, source: ProblemSource) -> CodeEditorPage {
        app.problemSelection().openProblem(slug: slug, source: source)
    }
}
