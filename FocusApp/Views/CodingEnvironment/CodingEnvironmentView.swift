import SwiftUI

struct CodingEnvironmentView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    let onBack: () -> Void
    @State var showProblemPicker = false
    @State var showProblemSidebar = false
    @State var detailTab: ProblemDetailTab = .description
    @State var isBottomPanelCollapsed = false
    @StateObject var focusPresenter = FocusPresenter()

    private let focusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .sheet(isPresented: $presenter.showSubmissionTagPrompt) {
            submissionTagSheet
        }
        .onAppear {
            presenter.ensureProblemSelection()
            startFocusIfNeeded()
        }
        .onChange(of: presenter.selectedProblem?.id) { _, _ in
            startFocusIfNeeded(forceRestart: true)
        }
        .onReceive(focusTimer) { _ in
            focusPresenter.handleTick()
        }
    }

    private func startFocusIfNeeded(forceRestart: Bool = false) {
        guard presenter.selectedProblem != nil else { return }
        if forceRestart || !focusPresenter.hasStarted {
            focusPresenter.duration = 30
            focusPresenter.startTimer()
        }
    }

    private var submissionTagSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.Coding.submissionTagTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(L10n.Coding.submissionTagBody)
                .font(.system(size: 12))
                .foregroundColor(Color.appGray400)

            TextField("e.g. Iterative, Recursive, Two pointers", text: $presenter.submissionTagInput)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Skip") {
                    presenter.confirmSubmissionTag(saveWithTag: false)
                }
                .buttonStyle(.plain)
                .foregroundColor(Color.appGray400)

                Spacer()

                Button("Save") {
                    presenter.confirmSubmissionTag(saveWithTag: true)
                }
                .buttonStyle(.plain)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.appPurple)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(20)
        .frame(width: 360)
        .background(Color.appGray900)
    }
}
