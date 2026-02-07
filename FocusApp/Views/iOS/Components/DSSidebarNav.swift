// DSSidebarNav.swift
// FocusApp — iPad sidebar navigation (260 x full height)
// Spec: FIGMA_SETUP_GUIDE.md §3.2

import SwiftUI

enum SidebarItem: String, CaseIterable {
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

struct DSSidebarNav: View {
    @Binding var selectedItem: SidebarItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("FocusApp")
                .font(DSTypography.section)
                .foregroundColor(DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.space24)
                .padding(.top, DSSpacing.space24)

            Spacer().frame(height: DSSpacing.space24)

            // Nav items
            VStack(spacing: DSSpacing.space4) {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        HStack(spacing: DSSpacing.space12) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                            Text(item.rawValue)
                                .font(DSTypography.body)
                        }
                        .foregroundColor(
                            selectedItem == item ? DSColor.purple : DSColor.gray500
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DSSpacing.space12)
                        .frame(height: 44)
                        .background(
                            selectedItem == item
                                ? DSColor.purple.opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(DSRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.space12)

            Spacer()

            // User profile
            HStack(spacing: DSSpacing.space12) {
                ZStack {
                    Circle()
                        .fill(DSColor.purple)
                        .frame(width: 36, height: 36)
                    Text("JD")
                        .font(DSTypography.subbodyStrong)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: DSSpacing.space2) {
                    Text("John Doe")
                        .font(DSTypography.subbodyStrong)
                        .foregroundColor(DSColor.gray900)
                    Text("Pro Plan")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.gray500)
                }
            }
            .padding(DSSpacing.space16)
        }
        .frame(width: 260)
        .background(DSColor.surface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(DSColor.divider)
                .frame(width: 1)
        }
    }
}

#Preview {
    DSSidebarNav(selectedItem: .constant(.today))
        .frame(height: 800)
}
