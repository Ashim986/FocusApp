import SwiftUI

struct DayCard: View {
    let day: Day
    @EnvironmentObject var dataStore: DataStore
    @State private var isExpanded = false

    private var completedCount: Int {
        dataStore.data.completedProblemsCount(day: day.id, totalProblems: day.problems.count)
    }

    private var isFullyCompleted: Bool {
        completedCount == day.problems.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 16) {
                    // Day badge
                    ZStack {
                        Circle()
                            .fill(isFullyCompleted ? Color.appGreen : Color.appPurple)
                            .frame(width: 40, height: 40)

                        if isFullyCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(day.id)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    // Topic and date
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.topic)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.appGray800)

                        Text(day.date)
                            .font(.system(size: 13))
                            .foregroundColor(Color.appGray500)
                    }

                    Spacer()

                    // Progress dots
                    HStack(spacing: 4) {
                        ForEach(0..<day.problems.count, id: \.self) { index in
                            Circle()
                                .fill(dataStore.isProblemCompleted(day: day.id, problemIndex: index) ? Color.appGreen : Color.appGray300)
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.appGray400)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(Array(day.problems.enumerated()), id: \.offset) { index, problem in
                        ProblemRow(
                            problem: problem,
                            isCompleted: dataStore.isProblemCompleted(day: day.id, problemIndex: index),
                            onToggle: {
                                dataStore.toggleProblem(day: day.id, problemIndex: index)
                            }
                        )

                        if index < day.problems.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isFullyCompleted ? Color.appGreen.opacity(0.3) : Color.appGray200, lineWidth: 1)
        )
    }
}

#Preview {
    DayCard(day: dsaPlan[0])
        .environmentObject(DataStore())
        .padding()
        .frame(width: 500)
        .background(Color.appGray100)
}
