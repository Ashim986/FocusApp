import SwiftUI

enum Tab: String, CaseIterable {
    case plan = "Plan"
    case today = "Today"
    case stats = "Stats"

    var icon: String {
        switch self {
        case .plan: return "list.bullet.clipboard"
        case .today: return "sun.max.fill"
        case .stats: return "chart.bar.fill"
        }
    }
}

struct ContentRouter {
    let makePlan: () -> PlanView
    let makeToday: (_ showFocusMode: Binding<Bool>, _ showCodeEnvironment: Binding<Bool>) -> TodayView
    let makeStats: () -> StatsView
    let makeFocus: (_ isPresented: Binding<Bool>) -> FocusOverlay
    let makeCoding: (_ isPresented: Binding<Bool>) -> CodingEnvironmentView
}

struct ContentView: View {
    @ObservedObject var presenter: ContentPresenter
    let router: ContentRouter
    @State private var showFocusMode = false
    @State private var showCodeEnvironment = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    header

                    Group {
                        switch presenter.selectedTab {
                        case .plan:
                            router.makePlan()
                        case .today:
                            router.makeToday($showFocusMode, $showCodeEnvironment)
                        case .stats:
                            router.makeStats()
                        }
                    }
                }
                .blur(radius: showFocusMode ? 10 : 0)

                if showFocusMode {
                    router.makeFocus($showFocusMode)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showFocusMode)
            .onAppear { presenter.onAppear() }
            .navigationDestination(isPresented: $showCodeEnvironment) {
                router.makeCoding($showCodeEnvironment)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FocusApp")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.appGray800)

                    Text("13-Day Interview Prep Plan")
                        .font(.system(size: 13))
                        .foregroundColor(Color.appGray500)
                }

                Spacer()

                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(presenter.solvedProblems)/\(presenter.totalProblems)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.appGray700)

                        Text("problems solved")
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
                }

                Button(action: { showFocusMode = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Focus")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.appPurple)
                    )
                }
                .buttonStyle(.plain)
                .padding(.leading, 16)
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
        Button(action: { presenter.selectedTab = tab }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))

                Text(tab.rawValue)
                    .font(.system(size: 13, weight: presenter.selectedTab == tab ? .semibold : .medium))
            }
            .foregroundColor(presenter.selectedTab == tab ? Color.appPurple : Color.appGray500)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(presenter.selectedTab == tab ? Color.white : Color.clear)
                    .shadow(color: presenter.selectedTab == tab ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
