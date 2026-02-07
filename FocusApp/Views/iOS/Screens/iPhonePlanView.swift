// iPhonePlanView.swift
// FocusApp -- iPhone Plan screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhonePlanView: View {
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    // Title
                    Text("Study Plan")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    // Calendar
                    calendarGrid
                        .padding(.horizontal, theme.spacing.lg)

                    // Schedule section
                    Text("Schedule for February 7th")
                        .font(theme.typography.subtitle)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    VStack(spacing: theme.spacing.sm) {
                        scheduleRow(
                            time: "09:00 AM",
                            title: "Morning Review",
                            subtitle: "Review yesterday's problems",
                            state: .active
                        )

                        scheduleRow(
                            time: "10:30 AM",
                            title: "Graph Theory",
                            subtitle: "BFS and DFS practice",
                            state: .normal
                        )

                        scheduleRow(
                            time: "02:00 PM",
                            title: "Mock Interview",
                            subtitle: "System Design with Peer",
                            state: .faded
                        )
                    }
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button { } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        CalendarGridContent(theme: theme)
    }

    // MARK: - Schedule Row

    private func scheduleRow(
        time: String,
        title: String,
        subtitle: String,
        state: ScheduleRowState
    ) -> some View {
        HStack(spacing: theme.spacing.lg) {
            Text(time)
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(state.timeColor)
                .frame(width: 60, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundColor(Color(hex: 0x6B7280))
            }

            Spacer()
        }
        .padding(theme.spacing.lg)
        .frame(height: 72)
        .background(state.backgroundColor)
        .cornerRadius(theme.radii.md)
        .opacity(state == .faded ? 0.5 : 1.0)
    }
}

// ScheduleRowState enum is defined in iPadPlanView.swift

// MARK: - Calendar Grid Content

private struct CalendarGridContent: View {
    let theme: DSTheme
    @State private var selectedDate: Int = 7
    private let month = "February 2026"
    private let weekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    private let daysInMonth = 28
    private let startOffset = 0

    var body: some View {
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
                    .font(theme.typography.subtitle)
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
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
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
                .font(theme.typography.body)
                .foregroundColor(Color(hex: 0x6B7280))
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    iPhonePlanView()
}
