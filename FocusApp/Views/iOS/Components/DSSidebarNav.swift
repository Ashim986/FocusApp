// LegacyDSSidebarNav.swift
// FocusApp — iPad sidebar navigation (260 x full height)
// Spec: FIGMA_SETUP_GUIDE.md §3.2

import SwiftUI

enum LegacySidebarItem: String, CaseIterable {
    case today = "Today"
    case plan = "Plan"
    case stats = "Stats"
    case focus = "Focus"
    case coding = "Coding"
    case settings = "Settings"

    var iconName: String {
        switch self {
        case .today: return "house"
        case .plan: return "calendar"
        case .stats: return "chart.bar"
        case .focus: return "bolt.fill"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .settings: return "gearshape"
        }
    }
}

struct LegacyDSSidebarNav: View {
    @Binding var selectedItem: LegacySidebarItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("FocusApp")
                .font(LegacyDSTypography.section)
                .foregroundColor(LegacyDSColor.textPrimary)
                .padding(.horizontal, DSLayout.spacing(.space24))
                .padding(.top, DSLayout.spacing(.space24))

            Spacer().frame(height: DSLayout.spacing(.space24))

            // Nav items
            VStack(spacing: DSLayout.spacing(.space4)) {
                ForEach(LegacySidebarItem.allCases, id: \.self) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        HStack(spacing: DSLayout.spacing(.space12)) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                            Text(item.rawValue)
                                .font(LegacyDSTypography.body)
                        }
                        .foregroundColor(
                            selectedItem == item ? LegacyDSColor.purple : LegacyDSColor.gray500
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DSLayout.spacing(.space12))
                        .frame(height: 44)
                        .background(
                            selectedItem == item
                                ? LegacyDSColor.purple.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(LegacyDSRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSLayout.spacing(.space12))

            Spacer()

            // User profile
            HStack(spacing: DSLayout.spacing(.space12)) {
                ZStack {
                    Circle()
                        .fill(LegacyDSColor.purple)
                        .frame(width: 36, height: 36)
                    Text("JD")
                        .font(LegacyDSTypography.subbodyStrong)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                    Text("John Doe")
                        .font(LegacyDSTypography.subbodyStrong)
                        .foregroundColor(LegacyDSColor.gray900)
                    Text("Pro Plan")
                        .font(LegacyDSTypography.caption)
                        .foregroundColor(LegacyDSColor.gray500)
                }
            }
            .padding(DSLayout.spacing(.space16))
        }
        .frame(width: 260)
        .background(LegacyDSColor.surface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(LegacyDSColor.divider)
                .frame(width: 1)
        }
    }
}

#Preview {
    LegacyDSSidebarNav(selectedItem: .constant(.today))
        .frame(height: 800)
}
