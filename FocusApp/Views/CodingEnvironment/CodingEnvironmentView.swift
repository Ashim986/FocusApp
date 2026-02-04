import SwiftUI

struct CodingEnvironmentView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void
    @State var showProblemPicker = false
    @State var showProblemSidebar = true
    @State var detailTab: ProblemDetailTab = .description
    @State var isBottomPanelCollapsed = false

    var body: some View {
        VStack(spacing: 0) {
            // Modern Header Bar
            headerBar

            // Main Content
            GeometryReader { proxy in
                let leftWidth = proxy.size.width * 0.4
                let rightWidth = max(proxy.size.width - leftWidth, 0)

                HSplitView {
                    leftPanel
                        .frame(width: leftWidth)

                    rightPanel
                        .frame(width: rightWidth)
                }
                .overlay(alignment: .leading) {
                    if showProblemSidebar {
                        problemSidebar
                            .frame(width: 280)
                            .transition(.move(edge: .leading))
                            .zIndex(1)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showProblemSidebar)
            }
        }
        .background(Color.appGray900)
        .onAppear {
            presenter.ensureProblemSelection()
        }
    }
}
