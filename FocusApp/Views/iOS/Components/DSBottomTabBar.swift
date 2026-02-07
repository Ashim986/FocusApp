// DSBottomTabBar.swift
// FocusApp — iPhone bottom tab bar (393x83)
// Spec: FIGMA_SETUP_GUIDE.md §3.1

import SwiftUI

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

struct DSBottomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(DSColor.divider)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: DSSpacing.space4) {
                            Image(systemName: selectedTab == tab ? tab.activeIconName : tab.iconName)
                                .font(.system(size: 24))
                                .frame(width: 24, height: 24)

                            Text(tab.rawValue)
                                .font(DSTypography.micro)
                        }
                        .foregroundColor(selectedTab == tab ? DSColor.purple : DSColor.gray400)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, DSSpacing.space8)
            .padding(.bottom, 34) // Safe area
        }
        .background(DSColor.surface)
    }
}

#Preview {
    DSBottomTabBar(selectedTab: .constant(.today))
}
