#if os(iOS)
// TodayViewIOS.swift
// FocusApp -- Unified Today screen for iPhone and iPad.
// Uses horizontalSizeClass to branch between compact (iPhone) and regular (iPad) layouts.

import FocusDesignSystem
import SwiftUI

struct TodayViewIOS: View {
    @ObservedObject var presenter: TodayPresenter
    var onSettingsTap: () -> Void
    var onStartFocus: () -> Void

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dsTheme) var theme
    @Environment(\.openURL) var openURL

    var body: some View {
        if sizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Shared Computed Properties

    var todayDay: TodayDayViewModel? {
        presenter.visibleDays.first(where: { $0.isToday })
    }

    var completedCount: Int {
        todayDay?.completedCount ?? 0
    }

    var totalCount: Int {
        todayDay?.totalCount ?? 0
    }

    var carryoverDays: [TodayDayViewModel] {
        presenter.visibleDays.filter { !$0.isToday && !$0.problems.isEmpty }
    }

    // MARK: - Date Formatter

    var formattedDateUppercased: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date()).uppercased()
    }
}

#endif
