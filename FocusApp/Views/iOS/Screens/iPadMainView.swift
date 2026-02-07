// iPadMainView.swift
// FocusApp — iPad main app shell with sidebar navigation
// Spec: Design-Spec.md Navigation Patterns § iPad

import FocusDesignSystem
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

struct iPadMainView: View {
    @Environment(\.dsTheme) var theme
    @State private var selectedItem: SidebarItem = .today

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar (260px)
            sidebarView

            // Content area
            Group {
                switch selectedItem {
                case .today:
                    iPadTodayView()
                case .plan:
                    iPadPlanView()
                case .stats:
                    iPadStatsView()
                case .focus:
                    iPadFocusView()
                case .coding:
                    iPadCodingView()
                case .settings:
                    iPadSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating help button
            Button { } label: {
                Text("?")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Color(hex: 0x1F2937))
                    .clipShape(Circle())
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
            .buttonStyle(.plain)
            .padding(theme.spacing.xl)
        }
        .background(theme.colors.background)
    }

    // MARK: - Sidebar

    private var sidebarView: some View {
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
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    Button {
                        selectedItem = item
                    } label: {
                        HStack(spacing: theme.spacing.md) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 18))
                                .frame(width: 20, height: 20)
                            Text(item.rawValue)
                                .font(.system(size: 16, weight: .regular))
                        }
                        .foregroundColor(
                            selectedItem == item
                                ? Color(hex: 0x6366F1)
                                : Color(hex: 0x6B7280)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, theme.spacing.md)
                        .frame(height: 44)
                        .background(
                            selectedItem == item
                                ? Color(hex: 0x6366F1).opacity(0.1)
                                : Color.clear
                        )
                        .cornerRadius(theme.radii.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.md)

            Spacer()

            // User profile
            HStack(spacing: theme.spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x6366F1))
                        .frame(width: 36, height: 36)
                    Text("JD")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("John Doe")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                    Text("Pro Plan")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
            .padding(theme.spacing.lg)
        }
        .frame(width: 260)
        .background(theme.colors.surface)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(theme.colors.border)
                .frame(width: 1)
        }
    }
}

#Preview("iPad 11\"") {
    iPadMainView()
        .frame(width: 834, height: 1194)
}
