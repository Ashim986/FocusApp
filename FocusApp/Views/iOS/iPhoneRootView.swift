#if os(iOS)
import FocusDesignSystem
import SwiftUI

/// iPhone root view with 5-tab bottom tab bar.
/// Settings is accessed via gear icon, not a tab.
struct iPhoneRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @Environment(\.dsTheme) var theme

    @State private var showSettings = false
    @State private var showCodingDetail = false

    private var container: AppContainer { coordinator.container }
    private var contentCoordinator: ContentCoordinator { coordinator.contentCoordinator }

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch contentCoordinator.selectedTab {
                case .today:
                    iPhoneTodayView(
                        presenter: container.todayPresenter,
                        onSettingsTap: { showSettings = true },
                        onStartFocus: { contentCoordinator.selectedTab = .focus }
                    )
                case .plan:
                    iPhonePlanView(presenter: container.planPresenter)
                case .stats:
                    iPhoneStatsView(presenter: container.statsPresenter)
                case .focus:
                    iPhoneFocusView(coordinator: coordinator.focusCoordinator)
                case .coding:
                    if showCodingDetail {
                        iPhoneCodingDetailView(
                            presenter: container.codingEnvironmentPresenter,
                            codingCoordinator: contentCoordinator.codingCoordinator,
                            focusCoordinator: coordinator.focusCoordinator,
                            onBack: { showCodingDetail = false }
                        )
                    } else {
                        iPhoneCodingListView(
                            presenter: container.codingEnvironmentPresenter,
                            onSelectProblem: { problem, day, index in
                                contentCoordinator.openCodingEnvironment(
                                    problem: problem, day: day, index: index
                                )
                                showCodingDetail = true
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: .infinity)

            // Bottom tab bar
            bottomTabBar
        }
        .sheet(isPresented: $showSettings) {
            iPhoneSettingsView(presenter: container.settingsPresenter)
        }
        .onChange(of: contentCoordinator.selectedTab) { _, _ in
            showCodingDetail = false
        }
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(Tab.iOSTabs, id: \.self) { tab in
                    Button {
                        contentCoordinator.selectedTab = tab
                    } label: {
                        VStack(spacing: theme.spacing.xs) {
                            Image(
                                systemName: contentCoordinator.selectedTab == tab
                                    ? tab.activeIcon
                                    : tab.icon
                            )
                            .font(.system(size: 24))
                            .frame(width: 24, height: 24)

                            Text(tab.title)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            contentCoordinator.selectedTab == tab
                                ? theme.colors.primary
                                : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, 34) // Safe area
        }
        .background(theme.colors.surface)
    }
}
#endif
