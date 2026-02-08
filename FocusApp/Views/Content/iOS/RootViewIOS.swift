#if os(iOS)
import FocusDesignSystem
import SwiftUI

/// Adaptive root view that handles both iPhone (bottom tab bar)
/// and iPad (NavigationSplitView + sidebar) layouts based on horizontalSizeClass.
///
/// Navigation is driven by `TabBarCoordinator` (via `coordinator.tabBarCoordinator`),
/// which owns per-tab flow coordinators and the settings coordinator.
struct RootViewIOS: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var tabBar: TabBarCoordinator
    @ObservedObject var settingsCoordinator: SettingsCoordinator
    @ObservedObject var codingFlow: CodingFlowCoordinator
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme

    private var container: AppContainer { coordinator.container }

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self.tabBar = coordinator.tabBarCoordinator
        self.settingsCoordinator = coordinator.tabBarCoordinator.settingsCoordinator
        self.codingFlow = coordinator.tabBarCoordinator.codingFlow
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
        .sheet(isPresented: settingsCoordinator.isPresentedBinding) {
            SettingsViewIOS(presenter: container.settingsPresenter)
        }
    }

    // MARK: - Screen Content (Shared by Both Layouts)

    @ViewBuilder
    private func screenContent() -> some View {
        switch tabBar.selectedTab {
        case .today:
            TodayViewIOS(
                presenter: container.todayPresenter,
                onSettingsTap: { tabBar.showSettings() },
                onStartFocus: { tabBar.switchToFocus() }
            )
        case .plan:
            PlanViewIOS(presenter: container.planPresenter)
        case .stats:
            StatsViewIOS(presenter: container.statsPresenter)
        case .focus:
            FocusViewIOS(coordinator: coordinator.focusCoordinator)
        case .coding:
            CodingViewIOS(
                presenter: container.codingEnvironmentPresenter,
                codingCoordinator: tabBar.codingFlow.codingCoordinator,
                focusCoordinator: coordinator.focusCoordinator,
                codingFlowCoordinator: tabBar.codingFlow
            )
        }
    }

    // MARK: - Compact Layout (iPhone / iPad Slide Over)

    private var compactLayout: some View {
        VStack(spacing: 0) {
            screenContent()
                .frame(maxHeight: .infinity)

            bottomTabBar
        }
    }

    // MARK: - Regular Layout (iPad)

    private var regularLayout: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            screenContent()
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - Bottom Tab Bar (Compact)

    private var bottomTabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(Tab.iOSTabs, id: \.self) { tab in
                    Button {
                        tabBar.selectedTab = tab
                    } label: {
                        VStack(spacing: theme.spacing.xs) {
                            Image(
                                systemName: tabBar.selectedTab == tab
                                    ? tab.activeIcon
                                    : tab.icon
                            )
                            .font(.system(size: 24))
                            .frame(width: 24, height: 24)

                            Text(tab.title)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            tabBar.selectedTab == tab
                                ? theme.colors.primary
                                : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, 34)
        }
        .background(theme.colors.surface)
    }

    // MARK: - Sidebar (Regular)

    private var sidebarContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("FocusApp")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.xl)

            Spacer().frame(height: theme.spacing.xl)

            VStack(spacing: theme.spacing.xs) {
                ForEach(Tab.iOSTabs, id: \.self) { tab in
                    Button {
                        tabBar.selectedTab = tab
                    } label: {
                        HStack(spacing: theme.spacing.md) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                            Text(tab.title)
                                .font(.system(size: 16, weight: .regular))
                        }
                        .foregroundColor(
                            tabBar.selectedTab == tab
                                ? theme.colors.primary
                                : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, theme.spacing.md)
                        .frame(height: 44)
                        .background(
                            tabBar.selectedTab == tab
                                ? theme.colors.primary.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(theme.radii.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.md)

            Spacer()

            Button {
                tabBar.showSettings()
            } label: {
                HStack(spacing: theme.spacing.md) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .frame(width: 20, height: 20)
                    Text("Settings")
                        .font(.system(size: 16, weight: .regular))
                }
                .foregroundColor(theme.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, theme.spacing.md)
                .frame(height: 44)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, theme.spacing.md)
            .padding(.bottom, theme.spacing.lg)
        }
        .frame(width: 260)
        .background(theme.colors.surface)
    }
}
#endif
