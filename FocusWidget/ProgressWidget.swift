import SwiftUI
import WidgetKit

// MARK: - Timeline Entry

struct ProgressEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Timeline Provider

struct ProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressEntry {
        ProgressEntry(date: Date(), data: .empty)
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        let data = WidgetDataReader.load()
        completion(ProgressEntry(date: Date(), data: data))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        let data = WidgetDataReader.load()
        let entry = ProgressEntry(date: Date(), data: data)
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Definition

struct ProgressWidget: Widget {
    let kind = "ProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressProvider()) { entry in
            ProgressWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("DSA Progress")
        .description("Track your daily DSA problem-solving progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Small Widget View

struct ProgressWidgetView: View {
    let entry: ProgressEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: Small

    private var smallView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: progressFraction)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 60, height: 60)

                VStack(spacing: 0) {
                    Text("\(entry.data.completedToday)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("/\(entry.data.totalToday)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }

            Text("Day \(entry.data.currentDay)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)

            Text(entry.data.topic)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Medium

    private var mediumView: some View {
        HStack(spacing: 16) {
            // Left side: Progress ring
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 5)
                        .frame(width: 50, height: 50)

                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 50, height: 50)

                    Text("\(Int(progressFraction * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

                Text("Day \(entry.data.currentDay)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Text(entry.data.topic)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: 80)

                // Habits row
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { idx in
                        Circle()
                            .fill(idx < entry.data.habitsCompleted ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }

            // Right side: Problem list
            VStack(alignment: .leading, spacing: 3) {
                ForEach(entry.data.problems.prefix(6)) { problem in
                    HStack(spacing: 4) {
                        Image(systemName: problem.isCompleted
                              ? "checkmark.circle.fill"
                              : "circle")
                            .font(.system(size: 10))
                            .foregroundColor(problem.isCompleted ? .green : .gray)

                        Text(problem.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Text(problem.difficulty)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(difficultyColor(problem.difficulty))
                    }
                }

                if entry.data.problems.count > 6 {
                    Text("+\(entry.data.problems.count - 6) more")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 4)
    }

    // MARK: Helpers

    private var progressFraction: CGFloat {
        guard entry.data.totalToday > 0 else { return 0 }
        return CGFloat(entry.data.completedToday) / CGFloat(entry.data.totalToday)
    }

    private var progressColor: Color {
        if progressFraction >= 1.0 { return .green }
        if progressFraction >= 0.5 { return .blue }
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

#Preview("Small", as: .systemSmall) {
    ProgressWidget()
} timeline: {
    ProgressEntry(date: Date(), data: WidgetData(
        currentDay: 5,
        topic: "Binary Search",
        completedToday: 3,
        totalToday: 5,
        totalCompleted: 45,
        totalProblems: 150,
        habitsCompleted: 2,
        habitsTotal: 3,
        problems: [
            WidgetProblem(id: "1", name: "Two Sum", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "2", name: "Binary Search", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "3", name: "Search Matrix", difficulty: "Medium", isCompleted: true),
            WidgetProblem(id: "4", name: "Koko Bananas", difficulty: "Medium", isCompleted: false),
            WidgetProblem(id: "5", name: "Min Rotated", difficulty: "Medium", isCompleted: false)
        ],
        lastUpdated: Date()
    ))
}

#Preview("Medium", as: .systemMedium) {
    ProgressWidget()
} timeline: {
    ProgressEntry(date: Date(), data: WidgetData(
        currentDay: 5,
        topic: "Binary Search",
        completedToday: 3,
        totalToday: 5,
        totalCompleted: 45,
        totalProblems: 150,
        habitsCompleted: 2,
        habitsTotal: 3,
        problems: [
            WidgetProblem(id: "1", name: "Two Sum", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "2", name: "Binary Search", difficulty: "Easy", isCompleted: true),
            WidgetProblem(id: "3", name: "Search Matrix", difficulty: "Medium", isCompleted: true),
            WidgetProblem(id: "4", name: "Koko Bananas", difficulty: "Medium", isCompleted: false),
            WidgetProblem(id: "5", name: "Min Rotated", difficulty: "Medium", isCompleted: false)
        ],
        lastUpdated: Date()
    ))
}
