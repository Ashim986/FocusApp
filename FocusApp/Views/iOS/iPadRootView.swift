#if os(iOS)
import FocusDesignSystem
import SwiftUI

/// iPad root view using NavigationSplitView with sidebar navigation.
/// 5 sidebar items + gear icon for settings at the bottom.
struct iPadRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @Environment(\.dsTheme) var theme

    @State private var showSettings = false

    private var container: AppContainer { coordinator.container }
    private var contentCoordinator: ContentCoordinator { coordinator.contentCoordinator }

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showSettings) {
            iPadSettingsView(presenter: container.settingsPresenter)
        }
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("FocusApp")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.xl)

            Spacer().frame(height: theme.spacing.xl)

            // Nav items
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

            // Settings button at bottom
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

    // MARK: - Detail Content

    @ViewBuilder
    private var detailContent: some View {
        switch contentCoordinator.selectedTab {
        case .today:
            iPadTodayView(presenter: container.todayPresenter)
        case .plan:
            iPadPlanView(presenter: container.planPresenter)
        case .stats:
            iPadStatsView(presenter: container.statsPresenter)
        case .focus:
            iPadFocusView(coordinator: coordinator.focusCoordinator)
        case .coding:
            iPadCodingView(
                presenter: container.codingEnvironmentPresenter,
                codingCoordinator: contentCoordinator.codingCoordinator,
                focusCoordinator: coordinator.focusCoordinator
            )
        }
    }
}
#endif
