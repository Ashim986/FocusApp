import FocusDesignSystem
import SwiftUI

struct CodingEnvironmentView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @ObservedObject var codingCoordinator: CodingCoordinator
    @ObservedObject var debugLogStore: DebugLogStore
    let onBack: () -> Void
    @StateObject var focusPresenter = FocusPresenter()
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    private let focusTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: DSLayout.spacing(0)) {
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
                    if codingCoordinator.isProblemSidebarShown {
                        problemSidebar
                            .frame(width: 280)
                            .transition(.move(edge: .leading))
                            .zIndex(1)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: codingCoordinator.isProblemSidebarShown)
            }
        }
        .background(theme.colors.background)
        .sheet(isPresented: $presenter.showSubmissionTagPrompt) {
            submissionTagSheet
        }
        .sheet(isPresented: $presenter.showLeetCodeLogin) {
            LeetCodeLoginSheet(
                onAuthCaptured: { auth in
                    presenter.updateLeetCodeAuth(auth)
                    presenter.showLeetCodeLogin = false
                },
                onClose: { presenter.showLeetCodeLogin = false }
            )
        }
        .sheet(item: $codingCoordinator.activeSheet) { sheet in
            switch sheet {
            case .debugLogs:
                DebugLogView(
                    store: debugLogStore,
                    onClose: { codingCoordinator.dismissSheet() }
                )
            case .submissionTag:
                EmptyView()
            }
        }
        .onAppear {
            presenter.ensureProblemSelection()
            startFocusIfNeeded()
        }
        .onChange(of: presenter.selectedProblem?.id) { _, _ in
            codingCoordinator.resetForNewProblem()
            startFocusIfNeeded(forceRestart: true)
        }
        .onReceive(focusTimer) { _ in
            focusPresenter.handleTick()
        }
        .onChange(of: presenter.isRunning) { _, isRunning in
            if isRunning, codingCoordinator.isBottomPanelCollapsed {
                withAnimation(.easeInOut(duration: 0.2)) {
                    codingCoordinator.isBottomPanelCollapsed = false
                }
            }
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
        DSCard(config: .init(style: .surface, padding: 20, cornerRadius: 12)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(16)) {
                DSHeader(
                    title: L10n.Coding.submissionTagTitle,
                    subtitle: L10n.Coding.submissionTagBody
                )

                DSTextField(
                    title: "",
                    placeholder: "e.g. Iterative, Recursive, Two pointers",
                    text: $presenter.submissionTagInput
                )

                HStack {
                    DSButton(
                        "Skip",
                        config: .init(style: .secondary, size: .small),
                        action: { presenter.confirmSubmissionTag(saveWithTag: false) }
                    )

                    Spacer()

                    DSButton(
                        "Save",
                        config: .init(style: .primary, size: .small),
                        action: { presenter.confirmSubmissionTag(saveWithTag: true) }
                    )
                }
            }
        }
        .frame(width: 360)
        .padding(DSLayout.spacing(16))
        .background(theme.colors.background)
    }
}
