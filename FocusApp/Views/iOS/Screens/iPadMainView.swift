// iPadMainView.swift
// FocusApp — iPad main app shell with sidebar navigation
// Spec: Design-Spec.md Navigation Patterns § iPad

import SwiftUI
import FocusDesignSystem

struct iPadMainView: View {
    @State private var selectedItem: SidebarItem = .today

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            DSSidebarNav(selectedItem: $selectedItem)

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
                    .font(DSMobileTypography.bodyStrong)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(DSMobileColor.gray800)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(DSLayout.spacing(.space24))
        }
        .background(DSMobileColor.background)
    }
}

#Preview("iPad 11\"") {
    iPadMainView()
        .frame(width: 834, height: 1194)
}
