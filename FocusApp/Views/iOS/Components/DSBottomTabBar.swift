// LegacyDSBottomTabBar.swift
// FocusApp — iPhone bottom tab bar (393x83)
// Spec: FIGMA_SETUP_GUIDE.md §3.1

import SwiftUI

enum LegacyAppTab: String, CaseIterable {
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

struct LegacyDSBottomTabBar: View {
    @Binding var selectedTab: LegacyAppTab

    var body: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(LegacyDSColor.divider)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(LegacyAppTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: DSLayout.spacing(.space4)) {
                            Image(systemName: selectedTab == tab ? tab.activeIconName : tab.iconName)
                                .font(.system(size: 24))
                                .frame(width: 24, height: 24)

                            Text(tab.rawValue)
                                .font(LegacyDSTypography.micro)
                        }
                        .foregroundColor(selectedTab == tab ? LegacyDSColor.purple : LegacyDSColor.gray400)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, DSLayout.spacing(.space8))
            .padding(.bottom, DSLayout.spacing(34)) // Safe area
        }
        .background(LegacyDSColor.surface)
    }
}

#Preview {
    LegacyDSBottomTabBar(selectedTab: .constant(.today))
}
