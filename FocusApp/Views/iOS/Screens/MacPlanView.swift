// MacPlanView.swift
// FocusApp -- Mac Plan screen (two-column layout)

import FocusDesignSystem
import SwiftUI

struct MacPlanView: View {
    @Environment(\.dsTheme) var theme

    @State private var selectedDate = 7

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text("Study Plan")
                .font(theme.typography.title)
                .foregroundColor(theme.colors.textPrimary)
                .padding(.horizontal, theme.spacing.xl)
                .padding(.top, theme.spacing.xl)

            // Two-column layout
            HStack(alignment: .top, spacing: theme.spacing.lg) {
                // Left column: Calendar grid (~50%)
                macCalendarGrid
                    .frame(maxWidth: .infinity)

                // Right column: Schedule (~50%)
                macScheduleColumn
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, theme.spacing.xl)

            Spacer()
        }
        .background(theme.colors.background)
    }

    // MARK: - Calendar Grid

    private var macCalendarGrid: some View {
        VStack(spacing: theme.spacing.md) {
            // Month header
            HStack {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("February 2026")
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                Button { } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }

            // Day-of-week headers
            let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: theme.spacing.sm) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day cells (Feb 2026 starts on Sunday)
            let days = macCalendarDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: theme.spacing.sm) {
                ForEach(days, id: \.self) { day in
                    if day == 0 {
                        Text("")
                            .frame(width: 36, height: 36)
                    } else {
                        Button {
                            selectedDate = day
                        } label: {
                            Text("\(day)")
                                .font(theme.typography.body)
                                .fontWeight(day == 7 ? .bold : .regular)
                                .foregroundColor(macDayTextColor(day))
                                .frame(width: 36, height: 36)
                                .background(macDayBackground(day))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
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

    private func macCalendarDays() -> [Int] {
        // Feb 2026 starts on Sunday, 28 days
        var days: [Int] = []
        for day in 1...28 {
            days.append(day)
        }
        return days
    }

    private func macDayTextColor(_ day: Int) -> Color {
        if day == selectedDate {
            return .white
        } else if day == 7 {
            return Color(hex: 0x6366F1)
        } else if day < 7 {
            return theme.colors.textPrimary
        } else {
            return theme.colors.textSecondary
        }
    }

    private func macDayBackground(_ day: Int) -> some ShapeStyle {
        if day == selectedDate {
            return AnyShapeStyle(Color(hex: 0x6366F1))
        } else if day == 7 {
            return AnyShapeStyle(Color(hex: 0x6366F1).opacity(0.1))
        } else {
            return AnyShapeStyle(Color.clear)
        }
    }

    // MARK: - Schedule Column

    private var macScheduleColumn: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Schedule for February \(selectedDate)th")
                .font(theme.typography.subtitle)
                .foregroundColor(theme.colors.textPrimary)

            macScheduleRow(
                time: "09:00 AM",
                title: "Morning Review",
                subtitle: "Review yesterday's problems",
                state: .active
            )

            macScheduleRow(
                time: "10:30 AM",
                title: "Graph Theory",
                subtitle: "BFS and DFS practice",
                state: .normal
            )

            macScheduleRow(
                time: "02:00 PM",
                title: "Mock Interview",
                subtitle: "System Design with Peer",
                state: .faded
            )

            macScheduleRow(
                time: "04:00 PM",
                title: "Dynamic Programming",
                subtitle: "Coin change variations",
                state: .faded
            )

            Spacer()
        }
    }

    // MARK: - Schedule Row

    private func macScheduleRow(
        time: String,
        title: String,
        subtitle: String,
        state: ScheduleRowState
    ) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            // Time label
            Text(time)
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(
                    state == .active ? Color(hex: 0x6366F1) : theme.colors.textSecondary
                )
                .frame(width: 72, alignment: .trailing)

            // Indicator dot
            Circle()
                .fill(state == .active ? Color(hex: 0x6366F1) : theme.colors.border)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            // Content
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        state == .faded ? theme.colors.textSecondary : theme.colors.textPrimary
                    )

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(theme.spacing.md)
        .background(
            state == .active
                ? Color(hex: 0x6366F1).opacity(0.05)
                : Color.clear
        )
        .cornerRadius(theme.radii.sm)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.sm)
                .stroke(
                    state == .active ? Color(hex: 0x6366F1).opacity(0.2) : Color.clear,
                    lineWidth: 1
                )
        )
        .opacity(state == .faded ? 0.6 : 1.0)
    }
}

// MARK: - Schedule Row State

enum ScheduleRowState {
    case active
    case normal
    case faded
}

#Preview("Mac Plan") {
    MacPlanView()
        .frame(width: 1200, height: 760)
}
