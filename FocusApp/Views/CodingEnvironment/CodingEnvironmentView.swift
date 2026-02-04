import SwiftUI

struct CodingEnvironmentView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void
    @State var showProblemPicker = false
    @State var detailTab: ProblemDetailTab = .description
    @State var isBottomPanelCollapsed = false

    var body: some View {
        VStack(spacing: 0) {
            // Modern Header Bar
            headerBar

            // Main Content
            HSplitView {
                leftPanel
                    .frame(minWidth: 280, idealWidth: 360, maxWidth: 420)

                rightPanel
                    .frame(minWidth: 720, idealWidth: 900, maxWidth: .infinity)
            }
        }
        .background(Color.appGray900)
        .onAppear {
            presenter.ensureProblemSelection()
        }
    }
}
