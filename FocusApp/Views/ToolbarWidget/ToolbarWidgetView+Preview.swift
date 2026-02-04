import SwiftData
import SwiftUI

#if DEBUG
struct ToolbarWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(
            for: AppDataRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
        let client = PreviewLeetCodeClient()
        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
        let presenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        return ToolbarWidgetView(presenter: presenter)
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
