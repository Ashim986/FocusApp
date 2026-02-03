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

struct ContentView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedTab: Tab = .today
    @State private var showFocusMode = false

    private var totalProblems: Int {
        dsaPlan.reduce(0) { $0 + $1.problems.count }
    }

    private var solvedProblems: Int {
        dataStore.data.totalCompletedProblems()
    }

    private var progressPercent: Double {
        guard totalProblems > 0 else { return 0 }
        return Double(solvedProblems) / Double(totalProblems)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                header

                // Tab content
                Group {
                    switch selectedTab {
                    case .plan:
                        PlanView()
                    case .today:
                        TodayView(showFocusMode: $showFocusMode)
                    case .stats:
                        StatsView()
                    }
                }
            }
            .blur(radius: showFocusMode ? 10 : 0)

            // Focus overlay
            if showFocusMode {
                FocusOverlay(isPresented: $showFocusMode)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showFocusMode)
    }

    private var header: some View {
        VStack(spacing: 16) {
            HStack {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("DSA Focus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.appGray800)

                    Text("13-Day Interview Prep Plan")
                        .font(.system(size: 13))
                        .foregroundColor(Color.appGray500)
                }

                Spacer()

                // Progress indicator
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(solvedProblems)/\(totalProblems)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.appGray700)

                        Text("problems solved")
                            .font(.system(size: 11))
                            .foregroundColor(Color.appGray500)
                    }

                    // Circular progress
                    ZStack {
                        Circle()
                            .stroke(Color.appGray200, lineWidth: 4)
                            .frame(width: 44, height: 44)

                        Circle()
                            .trim(from: 0, to: progressPercent)
                            .stroke(Color.appGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(progressPercent * 100))%")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray700)
                    }
                }

                // Focus button
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

            // Tab picker
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
        Button(action: { selectedTab = tab }) {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))

                Text(tab.rawValue)
                    .font(.system(size: 13, weight: selectedTab == tab ? .semibold : .medium))
            }
            .foregroundColor(selectedTab == tab ? Color.appPurple : Color.appGray500)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == tab ? Color.white : Color.clear)
                    .shadow(color: selectedTab == tab ? Color.black.opacity(0.05) : Color.clear, radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(DataStore())
        .frame(width: 800, height: 600)
}
