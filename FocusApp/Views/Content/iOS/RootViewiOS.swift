#if os(iOS)
import FocusDesignSystem
import SwiftUI

/// Adaptive root view that handles both iPhone (bottom tab bar)
/// and iPad (NavigationSplitView + sidebar) layouts based on horizontalSizeClass.
struct RootViewiOS: View {
    @ObservedObject var coordinator: AppCoordinator
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme

    @State private var showSettings = false
    @State private var showCodingDetail = false

    private var container: AppContainer { coordinator.container }
    private var contentCoordinator: ContentCoordinator { coordinator.contentCoordinator }

    var body: some View {
        Group {
            if sizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsViewiOS(presenter: container.settingsPresenter)
        }
        .onChange(of: contentCoordinator.selectedTab) { _, _ in
            showCodingDetail = false
        }
    }

    // MARK: - Screen Content (Shared by Both Layouts)

    @ViewBuilder
    private func screenContent() -> some View {
        switch contentCoordinator.selectedTab {
        case .today:
            TodayViewiOS(
                presenter: container.todayPresenter,
                onSettingsTap: { showSettings = true },
                onStartFocus: { contentCoordinator.selectedTab = .focus }
            )
        case .plan:
            PlanViewiOS(presenter: container.planPresenter)
        case .stats:
            StatsViewiOS(presenter: container.statsPresenter)
        case .focus:
            FocusViewiOS(coordinator: coordinator.focusCoordinator)
        case .coding:
            CodingViewiOS(
                presenter: container.codingEnvironmentPresenter,
                codingCoordinator: contentCoordinator.codingCoordinator,
                focusCoordinator: coordinator.focusCoordinator,
                contentCoordinator: contentCoordinator,
                showCodingDetail: $showCodingDetail
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
                        contentCoordinator.selectedTab = tab
                    } label: {
                        HStack(spacing: theme.spacing.md) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                            Text(tab.title)
                                .font(.system(size: 16, weight: .regular))
                        }
                        .foregroundColor(
                            contentCoordinator.selectedTab == tab
                                ? theme.colors.primary
                                : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, theme.spacing.md)
                        .frame(height: 44)
                        .background(
                            contentCoordinator.selectedTab == tab
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
                showSettings = true
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
