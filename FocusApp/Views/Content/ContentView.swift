import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

enum Tab: CaseIterable {
    case plan
    case today
    case stats

    var icon: String {
        switch self {
        case .plan: return "list.bullet.clipboard"
        case .today: return "sun.max.fill"
        case .stats: return "chart.bar.fill"
        }
    }

    var title: String {
        switch self {
        case .plan: return L10n.Tab.plan
        case .today: return L10n.Tab.today
        case .stats: return L10n.Tab.stats
        }
    }
}

struct ContentView: View {
    @ObservedObject var presenter: ContentPresenter
    @ObservedObject var coordinator: ContentCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
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
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Content.appTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.appGray800)

                    Text(L10n.Content.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.appGray500)
                }

                Spacer()

                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(L10n.Content.progressCount( presenter.solvedProblems, presenter.totalProblems))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.appGray700)

                        Text(L10n.Content.problemsSolved)
                            .font(.system(size: 11))
                            .foregroundColor(Color.appGray500)
                    }

                    ZStack {
                        Circle()
                            .stroke(Color.appGray200, lineWidth: 4)
                            .frame(width: 44, height: 44)

                        Circle()
                            .trim(from: 0, to: presenter.progressPercent)
                            .stroke(Color.appGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(presenter.progressPercent * 100))%")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray700)
                    }

                    Button(action: openSettings) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 12, weight: .semibold))
                            Text(L10n.Content.settingsButton)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color.appGray700)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appGray100)
                        )
                    }
                    .buttonStyle(.plain)
                    .help(L10n.Content.settingsButton)
                }

            }

            HStack(spacing: 4) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tabButton(tab)
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appGray100)
            )
        }
        .padding(20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }

    private func tabButton(_ tab: Tab) -> some View {
        Button(action: {
            coordinator.selectTab(tab)
        }, label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))

                Text(tab.title)
                    .font(.system(
                        size: 13,
                        weight: coordinator.selectedTab == tab ? .semibold : .medium
                    ))
            }
            .foregroundColor(coordinator.selectedTab == tab ? Color.appPurple : Color.appGray500)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(coordinator.selectedTab == tab ? Color.white : Color.clear)
                    .shadow(
                        color: coordinator.selectedTab == tab ? Color.black.opacity(0.05) : Color.clear,
                        radius: 2,
                        x: 0,
                        y: 1
                    )
            )
        })
        .buttonStyle(.plain)
    }

    private func openSettings() {
        #if canImport(AppKit)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        #endif
    }
}
