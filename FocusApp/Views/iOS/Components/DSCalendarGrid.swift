// LegacyDSCalendarGrid.swift
// FocusApp — Calendar grid component
// Spec: FIGMA_SETUP_GUIDE.md §3.16

import SwiftUI

struct LegacyDSCalendarGrid: View {
    @State private var selectedDate: Int = 7
    var month: String = "February 2026"

    private let weekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    // February 2026 starts on Sunday (day 1 = column 0)
    private let daysInMonth = 28
    private let startOffset = 0 // Sunday = 0

    var body: some View {
        LegacyDSSurfaceCard {
            VStack(spacing: DSLayout.spacing(.space16)) {
                // Header: Month + arrows
                HStack {
                    Button { } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(LegacyDSColor.gray500)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(month)
                        .font(LegacyDSTypography.section)
                        .foregroundColor(LegacyDSColor.textPrimary)

                    Spacer()

                    Button { } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(LegacyDSColor.gray500)
                    }
                    .buttonStyle(.plain)
                }

                // Weekday labels
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(LegacyDSTypography.captionStrong)
                            .foregroundColor(LegacyDSColor.gray400)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Date grid
                let totalCells = startOffset + daysInMonth
                let rows = (totalCells + 6) / 7

                VStack(spacing: DSLayout.spacing(.space4)) {
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
                                                    .fill(LegacyDSColor.purple)
                                                    .frame(width: 36, height: 36)
                                            }

                                            Text("\(day)")
                                                .font(LegacyDSTypography.body)
                                                .foregroundColor(
                                                    day == selectedDate
                                                        ? .white
                                                        : LegacyDSColor.gray900
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
                    .font(LegacyDSTypography.subbody)
                    .foregroundColor(LegacyDSColor.gray500)
            }
        }
    }
}

#Preview {
    LegacyDSCalendarGrid()
        .padding()
}
