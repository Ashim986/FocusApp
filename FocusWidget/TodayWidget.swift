import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct TodayEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Timeline Provider

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        let data = WidgetDataReader.load()
        completion(TodayEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let data = WidgetDataReader.load()
        let entry = TodayEntry(date: Date(), data: data)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Definition

struct TodayWidget: Widget {
    let kind = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Problems")
        .description("See today's DSA problems with completion status.")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Large Widget View

struct TodayWidgetView: View {
    let entry: TodayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Day \(entry.data.currentDay)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(entry.data.topic)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Overall progress
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(entry.data.totalCompleted)/\(entry.data.totalProblems)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("overall")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(todayProgressColor)
                        .frame(
                            width: max(
                                0,
                                geometry.size.width * todayProgressFraction
                            ),
                            height: 6
                        )
                }
            }
            .frame(height: 6)

            Text("\(entry.data.completedToday)/\(entry.data.totalToday) solved today")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)

            Divider()

            // Problem list
            ForEach(entry.data.problems.prefix(10)) { problem in
                HStack(spacing: 6) {
                    Image(systemName: problem.isCompleted
                          ? "checkmark.circle.fill"
                          : "circle")
                        .font(.system(size: 13))
                        .foregroundColor(problem.isCompleted ? .green : .gray.opacity(0.5))

                    Text(problem.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .strikethrough(problem.isCompleted, color: .secondary)

                    Spacer(minLength: 0)

                    Text(problem.difficulty)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(difficultyColor(problem.difficulty))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(difficultyColor(problem.difficulty).opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            if entry.data.problems.count > 10 {
                Text("+\(entry.data.problems.count - 10) more problems")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer(minLength: 0)

            // Habits row
            HStack(spacing: 12) {
                ForEach(["DSA", "Exercise", "Other"], id: \.self) { habit in
                    let idx = ["DSA", "Exercise", "Other"].firstIndex(of: habit) ?? 0
                    let isDone = idx < entry.data.habitsCompleted
                    HStack(spacing: 3) {
                        Image(systemName: isDone ? "checkmark.square.fill" : "square")
                            .font(.system(size: 10))
                            .foregroundColor(isDone ? .green : .gray)
                        Text(habit)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isDone ? .primary : .secondary)
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 4)
    }

    // MARK: Helpers

    private var todayProgressFraction: CGFloat {
        guard entry.data.totalToday > 0 else { return 0 }
        return CGFloat(entry.data.completedToday) / CGFloat(entry.data.totalToday)
    }

    private var todayProgressColor: Color {
        if todayProgressFraction >= 1.0 { return .green }
        if todayProgressFraction >= 0.5 { return .blue }
        return .orange
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }
}

// MARK: - Preview

#Preview("Large", as: .systemLarge) {
    TodayWidget()
} timeline: {
    TodayEntry(date: Date(), data: WidgetData(
        currentDay: 5,
        topic: "Binary Search",
        completedToday: 3,
        totalToday: 7,
        totalCompleted: 45,
        totalProblems: 150,
        habitsCompleted: 2,
        habitsTotal: 3,
        problems: [
            WidgetProblem(id: "1", name: "Two Sum", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "2", name: "Binary Search", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "3", name: "Search 2D Matrix", difficulty: "Medium", isCompleted: true),
            WidgetProblem(id: "4", name: "Koko Eating Bananas", difficulty: "Medium", isCompleted: false),
            WidgetProblem(id: "5", name: "Min in Rotated Array", difficulty: "Medium", isCompleted: false),
            WidgetProblem(id: "6", name: "Time Based Store", difficulty: "Medium", isCompleted: false),
            WidgetProblem(id: "7", name: "Median Two Arrays", difficulty: "Hard", isCompleted: false)
        ],
        lastUpdated: Date()
    ))
}
