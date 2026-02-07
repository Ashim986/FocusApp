// iPhoneMainView.swift
// FocusApp — iPhone main app shell with tab navigation
// Spec: Design-Spec.md Navigation Patterns § iPhone

import SwiftUI
import FocusDesignSystem

struct iPhoneMainView: View {
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
            DSBottomTabBar(selectedTab: $selectedTab)
        }
        .sheet(isPresented: $showSettings) {
            iPhoneSettingsView()
        }
        .onChange(of: selectedTab) { _, _ in
            showCodingDetail = false
        }
    }
}

#Preview("iPhone 15") {
    iPhoneMainView()
        .frame(width: 393, height: 852)
}
