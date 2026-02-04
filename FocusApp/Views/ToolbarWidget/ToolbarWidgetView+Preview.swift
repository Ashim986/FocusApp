import SwiftData
import SwiftUI

#if DEBUG
struct ToolbarWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            if let container = try? ModelContainer(for: AppDataRecord.self) {
                let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
                let client = PreviewLeetCodeClient()
                let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
                let presenter = ToolbarWidgetPresenter(
                    interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
                )
                ToolbarWidgetView(presenter: presenter)
            } else {
                Text("Preview unavailable")
            }
        }
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
