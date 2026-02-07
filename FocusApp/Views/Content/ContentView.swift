import FocusDesignSystem
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

enum Tab: Hashable {
    case plan
    case today
    case stats
    case focus
    case coding

    /// Tabs shown in the macOS segmented control header.
    static let macTabs: [Tab] = [.plan, .today, .stats]

    /// Tabs shown in the iOS bottom tab bar / iPad sidebar.
    static let iOSTabs: [Tab] = [.today, .plan, .stats, .focus, .coding]

    var icon: String {
        switch self {
        case .plan: return "list.bullet.clipboard"
        case .today: return "sun.max.fill"
        case .stats: return "chart.bar.fill"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var activeIcon: String {
        switch self {
        case .today: return "house.fill"
        case .plan: return "calendar"
        case .stats: return "chart.bar.fill"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var title: String {
        switch self {
        case .plan: return L10n.Tab.plan
        case .today: return L10n.Tab.today
        case .stats: return L10n.Tab.stats
        case .focus: return "Focus"
        case .coding: return "Coding"
        }
    }

    var id: String {
        switch self {
        case .plan: return "plan"
        case .today: return "today"
        case .stats: return "stats"
        case .focus: return "focus"
        case .coding: return "coding"
        }
    }
}

struct ContentView: View {
    @ObservedObject var presenter: ContentPresenter
    @ObservedObject var coordinator: ContentCoordinator
    @Environment(\.dsTheme) var theme

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: DSLayout.spacing(0)) {
                    header

                    Group {
                        switch coordinator.selectedTab {
                        case .plan:
                            PlanView(
                                presenter: coordinator.container.planPresenter,
                                onSelectProblem: { problem, day, index in
                                    coordinator.openCodingEnvironment(
                                        problem: problem, day: day, index: index
                                    )
                                }
                            )
                        case .today:
                            TodayView(
                                presenter: coordinator.container.todayPresenter,
                                onOpenCodingEnvironment: {
                                    coordinator.openCodingEnvironmentGeneric()
                                },
                                onSelectProblem: { problem, day, index in
                                    coordinator.openCodingEnvironment(
                                        problem: problem, day: day, index: index
                                    )
                                }
                            )
                        case .stats:
                            StatsView(presenter: coordinator.container.statsPresenter)
                        case .focus, .coding:
                            // iOS-only tabs; on macOS these are handled
                            // via the coding overlay and focus mode
                            EmptyView()
                        }
                    }
                }
                .allowsHitTesting(!coordinator.isCodingPresented)

                if coordinator.isCodingPresented {
                    CodingEnvironmentView(
                        presenter: coordinator.container.codingEnvironmentPresenter,
                        codingCoordinator: coordinator.codingCoordinator,
                        debugLogStore: coordinator.container.debugLogStore,
                        onBack: { coordinator.closeCodingEnvironment() }
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: coordinator.isCodingPresented)
            .onAppear { presenter.onAppear() }
        }
    }

    private var header: some View {
        VStack(spacing: DSLayout.spacing(.space16)) {
            HStack {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text(L10n.Content.appTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(L10n.Content.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                HStack(spacing: DSLayout.spacing(.space12)) {
                    VStack(alignment: .trailing, spacing: DSLayout.spacing(.space2)) {
                        Text(L10n.Content.progressCount( presenter.solvedProblems, presenter.totalProblems))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)

                        Text(L10n.Content.problemsSolved)
                            .font(.system(size: 11))
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    ZStack {
                        DSProgressRing(
                            config: .init(size: 44, lineWidth: 4, style: .secondary),
                            state: .init(progress: presenter.progressPercent)
                        )

                        Text("\(Int(presenter.progressPercent * 100))%")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                    }

                    DSButton(
                        L10n.Content.settingsButton,
                        config: .init(
                            style: .secondary,
                            size: .small,
                            icon: Image(systemName: "slider.horizontal.3"),
                            iconPosition: .leading
                        )
                    ) {
                        openSettings()
                    }
                    .help(L10n.Content.settingsButton)
                }

            }

            DSSegmentedControl(
                items: Tab.macTabs.map { DSSegmentItem(id: $0.id, title: $0.title) },
                state: .init(selectedId: coordinator.selectedTab.id),
                onSelect: { selected in
                    if let tab = Tab.macTabs.first(where: { $0.id == selected }) {
                        coordinator.selectTab(tab)
                    }
                }
            )
        }
        .padding(DSLayout.spacing(20))
        .background(theme.colors.surface)
        .shadow(color: theme.shadow.color, radius: theme.shadow.radius, x: theme.shadow.x, y: theme.shadow.y)
    }

    private func openSettings() {
        #if canImport(AppKit)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        #endif
    }
}
