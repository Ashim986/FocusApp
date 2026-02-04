import SwiftUI

#if DEBUG
struct ToolbarWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        let appStore = AppStateStore(storage: FileAppStorage())
        let client = LeetCodeRestClient(
            baseURL: LeetCodeConstants.restBaseURL,
            requestBuilder: DefaultRequestBuilder(),
            executor: URLSessionRequestExecutor()
        )
        let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
        let presenter = ToolbarWidgetPresenter(
            interactor: ToolbarWidgetInteractor(appStore: appStore, leetCodeSync: leetCodeSync)
        )
        return ToolbarWidgetView(presenter: presenter)
    }
}
#endif
