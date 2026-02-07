// iPadPlanView.swift
// FocusApp — iPad Plan screen (two-column layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.2

import FocusDesignSystem
import SwiftUI

// MARK: - Schedule Row State

enum ScheduleRowState {
    case active
    case normal
    case faded
}

struct iPadPlanView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text("Study Plan")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.xl)

            // Two-column layout
            HStack(alignment: .top, spacing: theme.spacing.md) {
                // Left column: Calendar
                calendarGrid

                // Right column: Schedule
                scheduleColumn
            }
            .padding(.horizontal, theme.spacing.xl)

            Spacer()
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        iPadCalendarGridView(theme: theme)
    }

    // MARK: - Schedule Column

    private var scheduleColumn: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Schedule for February 7th")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.colors.textPrimary)

            iPadScheduleRow(
                time: "09:00 AM",
                title: "Morning Review",
                subtitle: "Review yesterday's problems",
                state: .active,
                theme: theme
            )

            iPadScheduleRow(
                time: "10:30 AM",
                title: "Graph Theory",
                subtitle: "BFS and DFS practice",
                state: .normal,
                theme: theme
            )

            iPadScheduleRow(
                time: "02:00 PM",
                title: "Mock Interview",
                subtitle: "System Design with Peer",
                state: .faded,
                theme: theme
            )

            Spacer()
        }
    }
}

// MARK: - Calendar Grid View

private struct iPadCalendarGridView: View {
    var theme: DSTheme
    @State private var selectedDate: Int = 7
    var month: String = "February 2026"

    private let weekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    private let daysInMonth = 28
    private let startOffset = 0

    var body: some View {
        DSCard(config: DSCardConfig(style: .outlined)) {
            VStack(spacing: theme.spacing.lg) {
                // Header: Month + arrows
                HStack {
                    Button { } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: 0x6B7280))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(month)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Button { } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: 0x6B7280))
                    }
                    .buttonStyle(.plain)
                }

                // Weekday labels
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: 0x9CA3AF))
                            .frame(maxWidth: .infinity)
                    }
                }

                // Date grid
                let totalCells = startOffset + daysInMonth
                let rows = (totalCells + 6) / 7

                VStack(spacing: theme.spacing.xs) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { col in
                                let index = row * 7 + col
                                let day = index - startOffset + 1

                                if day >= 1 && day <= daysInMonth {
                                    Button {
                                        selectedDate = day
                                    } label: {
                                        ZStack {
                                            if day == selectedDate {
                                                Circle()
                                                    .fill(Color(hex: 0x6366F1))
                                                    .frame(width: 36, height: 36)
                                            }

                                            Text("\(day)")
                                                .font(theme.typography.body)
                                                .foregroundColor(
                                                    day == selectedDate
                                                        ? .white
                                                        : theme.colors.textPrimary
                                                )
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                }
                            }
                        }
                    }
                }

                // Selected date label
                Text("You selected Feb \(selectedDate), 2026.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: 0x6B7280))
            }
        }
    }
}

// MARK: - Schedule Row

private struct iPadScheduleRow: View {
    var time: String
    var title: String
    var subtitle: String
    var state: ScheduleRowState = .normal
    var theme: DSTheme

    var body: some View {
        HStack(spacing: theme.spacing.lg) {
            Text(time)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(timeColor)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            Spacer()
        }
        .padding(theme.spacing.lg)
        .frame(height: 72)
        .background(backgroundColor)
        .cornerRadius(theme.radii.md)
        .opacity(state == .faded ? 0.5 : 1.0)
    }

    private var timeColor: Color {
        switch state {
        case .active: return Color(hex: 0x6366F1)
        case .normal: return Color(hex: 0x6B7280)
        case .faded: return Color(hex: 0x9CA3AF)
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .active: return Color(hex: 0x6366F1).opacity(0.08)
        case .normal, .faded: return Color.clear
        }
    }
}

#Preview {
    iPadPlanView()
        .frame(width: 574, height: 1194)
}
