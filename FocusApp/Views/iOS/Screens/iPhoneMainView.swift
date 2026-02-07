// iPhoneMainView.swift
// FocusApp -- iPhone main app shell with tab navigation

import FocusDesignSystem
import SwiftUI

// MARK: - App Tab

enum AppTab: String, CaseIterable {
    case today = "Today"
    case plan = "Plan"
    case stats = "Stats"
    case focus = "Focus"
    case coding = "Coding"

    var iconName: String {
        switch self {
        case .today: return "house"
        case .plan: return "calendar"
        case .stats: return "chart.bar"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }

    var activeIconName: String {
        switch self {
        case .today: return "house.fill"
        case .plan: return "calendar"
        case .stats: return "chart.bar.fill"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        }
    }
}

struct iPhoneMainView: View {
    @Environment(\.dsTheme) var theme

    @State private var selectedTab: AppTab = .today
    @State private var showSettings = false
    @State private var showCodingDetail = false

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case .today:
                    iPhoneTodayView(
                        onSettingsTap: { showSettings = true },
                        onStartFocus: { selectedTab = .focus }
                    )
                case .plan:
                    iPhonePlanView()
                case .stats:
                    iPhoneStatsView()
                case .focus:
                    iPhoneFocusView()
                case .coding:
                    if showCodingDetail {
                        iPhoneCodingDetailView(
                            onBack: { showCodingDetail = false }
                        )
                    } else {
                        iPhoneCodingListView()
                    }
                }
            }
            .frame(maxHeight: .infinity)

            // Tab bar
            bottomTabBar
        }
        .sheet(isPresented: $showSettings) {
            iPhoneSettingsView()
        }
        .onChange(of: selectedTab) { _, _ in
            showCodingDetail = false
        }
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(theme.colors.border)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: theme.spacing.xs) {
                            Image(
                                systemName: selectedTab == tab
                                    ? tab.activeIconName
                                    : tab.iconName
                            )
                            .font(.system(size: 24))
                            .frame(width: 24, height: 24)

                            Text(tab.rawValue)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(
                            selectedTab == tab
                                ? Color(hex: 0x6366F1)
                                : Color(hex: 0x9CA3AF)
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

#Preview("iPhone 15") {
    iPhoneMainView()
        .frame(width: 393, height: 852)
}
