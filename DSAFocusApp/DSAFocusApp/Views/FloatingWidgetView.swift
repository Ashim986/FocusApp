import SwiftUI
import AppKit

struct FloatingWidgetView: View {
    @EnvironmentObject var dataStore: DataStore
    var onClose: () -> Void
    @State private var showTomorrow: Bool = false
    @State private var showSettings: Bool = false
    @State private var editingUsername: String = ""

    private var progressPercentage: Double {
        let totalProblems = dsaPlan.reduce(0) { $0 + $1.problems.count }
        let completed = dataStore.data.totalCompletedProblems()
        guard totalProblems > 0 else { return 0 }
        return Double(completed) / Double(totalProblems) * 100
    }

    private var currentDayNumber: Int {
        dataStore.currentDayNumber()
    }

    private var todaysTopic: String {
        guard let dayData = dsaPlan.first(where: { $0.id == currentDayNumber }) else { return "Complete!" }
        return dayData.topic
    }

    private var todaysProblems: [Problem] {
        let day = currentDayNumber
        guard let dayData = dsaPlan.first(where: { $0.id == day }) else { return [] }
        return dayData.problems
    }

    private var habitsCompletedToday: Int {
        dataStore.data.todayHabitsCount()
    }

    // Tomorrow's data
    private var tomorrowDayNumber: Int {
        min(currentDayNumber + 1, 13)
    }

    private var tomorrowsTopic: String {
        guard let dayData = dsaPlan.first(where: { $0.id == tomorrowDayNumber }) else { return "Complete!" }
        return dayData.topic
    }

    private var tomorrowsProblems: [Problem] {
        guard let dayData = dsaPlan.first(where: { $0.id == tomorrowDayNumber }) else { return [] }
        return dayData.problems
    }

    // Unsolved problems from today (carryover)
    private var carryoverProblems: [(index: Int, problem: Problem)] {
        todaysProblems.enumerated().compactMap { index, problem in
            dataStore.isProblemCompleted(day: currentDayNumber, problemIndex: index) ? nil : (index, problem)
        }
    }

    private var hasTomorrow: Bool {
        currentDayNumber < 13
    }

    // Check if all today's problems are solved
    private var allTodaysSolved: Bool {
        guard !todaysProblems.isEmpty else { return false }
        return todaysProblems.enumerated().allSatisfy { index, _ in
            dataStore.isProblemCompleted(day: currentDayNumber, problemIndex: index)
        }
    }

    // Border color for username field based on validation status
    private var validationBorderColor: Color {
        switch dataStore.usernameValidationResult {
        case .valid:
            return .green
        case .invalid, .error:
            return .red
        case .none:
            return .clear
        }
    }

    // Validate and save username, then trigger sync
    private func saveUsername() {
        let trimmed = editingUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        dataStore.validateAndUpdateUsername(trimmed) { isValid in
            if isValid {
                dataStore.syncWithLeetCode()
                withAnimation {
                    showSettings = false
                }
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with sync and close buttons
            HStack {
                Text("DSA Focus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))

                if !dataStore.lastSyncResult.isEmpty {
                    Text(dataStore.lastSyncResult)
                        .font(.system(size: 9))
                        .foregroundColor(.green.opacity(0.8))
                }

                Spacer()

                // Sync button
                Button(action: {
                    dataStore.syncWithLeetCode()
                }) {
                    Image(systemName: dataStore.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.triangle.2.circlepath")
                        .font(.system(size: 12))
                        .foregroundColor(dataStore.isSyncing ? .green : .white.opacity(0.5))
                        .rotationEffect(.degrees(dataStore.isSyncing ? 360 : 0))
                        .animation(dataStore.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: dataStore.isSyncing)
                }
                .buttonStyle(.plain)
                .disabled(dataStore.isSyncing)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .help("Sync with LeetCode")

                // Settings button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                        if showSettings {
                            editingUsername = dataStore.leetCodeUsername
                        }
                    }
                }) {
                    Image(systemName: showSettings ? "gearshape.fill" : "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(showSettings ? .blue : .white.opacity(0.5))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .help("Settings")

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)

            Divider()
                .background(Color.white.opacity(0.1))

            // Settings Section (collapsible)
            if showSettings {
                VStack(spacing: 8) {
                    HStack {
                        Text("LeetCode Username")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()

                        // Validation status indicator
                        switch dataStore.usernameValidationResult {
                        case .valid:
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("Valid")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.green)
                        case .invalid:
                            HStack(spacing: 2) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                Text("User not found")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.red)
                        case .error(let message):
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 10))
                                Text(message.prefix(20) + "...")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.orange)
                        case .none:
                            EmptyView()
                        }
                    }

                    HStack(spacing: 8) {
                        TextField("Username", text: $editingUsername)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(validationBorderColor, lineWidth: 1)
                            )
                            .onSubmit {
                                saveUsername()
                            }
                            .onChange(of: editingUsername) { _ in
                                dataStore.resetUsernameValidation()
                            }

                        Button(action: saveUsername) {
                            HStack(spacing: 4) {
                                if dataStore.isValidatingUsername {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .frame(width: 12, height: 12)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 10))
                                }
                                Text(dataStore.isValidatingUsername ? "Checking..." : "Save & Sync")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(dataStore.isValidatingUsername ? Color.gray : Color.blue)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(dataStore.isValidatingUsername)
                        .onHover { hovering in
                            if hovering && !dataStore.isValidatingUsername {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }

                    HStack {
                        Image(systemName: "info.circle")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        Text("Your LeetCode profile must be public")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))

                Divider()
                    .background(Color.white.opacity(0.1))
            }

            // Day info and progress
            HStack(spacing: 12) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 5)

                    Circle()
                        .trim(from: 0, to: progressPercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progressPercentage))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Day \(currentDayNumber)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)

                        Text("of 13")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }

                    Text(todaysTopic)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.purple)
                        .lineLimit(1)
                }

                Spacer()

                // Habits summary
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Habits")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                    Text("\(habitsCompletedToday)/3")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(habitsCompletedToday == 3 ? .green : .white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()
                .background(Color.white.opacity(0.1))

            // Today's Problems Header
            HStack {
                Text("Today's Problems")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                let solved = todaysProblems.enumerated().filter { dataStore.isProblemCompleted(day: currentDayNumber, problemIndex: $0.offset) }.count
                Text("\(solved)/\(todaysProblems.count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(solved == todaysProblems.count ? .green : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Problems List
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(Array(todaysProblems.enumerated()), id: \.element.id) { index, problem in
                        ProblemRowWidget(
                            problem: problem,
                            isCompleted: dataStore.isProblemCompleted(day: currentDayNumber, problemIndex: index),
                            onRefresh: {
                                dataStore.syncWithLeetCode()
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(maxHeight: 200)

            // All problems solved - show next day button
            if allTodaysSolved && hasTomorrow {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("All done!")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                    Spacer()
                    Button(action: {
                        dataStore.advanceToNextDay()
                    }) {
                        HStack(spacing: 4) {
                            Text("Start Day \(tomorrowDayNumber)")
                                .font(.system(size: 10, weight: .semibold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { hovering in
                        if hovering {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Quick habits
            HStack(spacing: 8) {
                HabitToggle(label: "DSA", icon: "book.fill", done: dataStore.isHabitDone("dsa")) {
                    dataStore.toggleHabit("dsa")
                }
                HabitToggle(label: "Exercise", icon: "figure.run", done: dataStore.isHabitDone("exercise")) {
                    dataStore.toggleHabit("exercise")
                }
                HabitToggle(label: "Other", icon: "lightbulb.fill", done: dataStore.isHabitDone("other")) {
                    dataStore.toggleHabit("other")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            // Tomorrow's Preview Section
            if hasTomorrow || !carryoverProblems.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.1))

                // Collapsible Tomorrow Header
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showTomorrow.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: showTomorrow ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .frame(width: 12)

                        Text("Tomorrow")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))

                        if !carryoverProblems.isEmpty {
                            Text("(\(carryoverProblems.count) carryover)")
                                .font(.system(size: 9))
                                .foregroundColor(.orange.opacity(0.8))
                        }

                        Spacer()

                        if hasTomorrow {
                            Text("Day \(tomorrowDayNumber)")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                if showTomorrow {
                    VStack(spacing: 0) {
                        // Carryover problems from today
                        if !carryoverProblems.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "arrow.uturn.forward")
                                        .font(.system(size: 9))
                                        .foregroundColor(.orange)
                                    Text("Carryover from Today")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 4)

                                ForEach(carryoverProblems, id: \.problem.id) { item in
                                    CarryoverProblemRow(
                                        problem: item.problem,
                                        onToggle: {
                                            dataStore.toggleProblem(day: currentDayNumber, problemIndex: item.index)
                                        }
                                    )
                                }
                                .padding(.horizontal, 8)
                            }
                            .padding(.bottom, 8)
                        }

                        // Tomorrow's topic and problems
                        if hasTomorrow {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 9))
                                        .foregroundColor(.blue)
                                    Text(tomorrowsTopic)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Text("\(tomorrowsProblems.count) problems")
                                        .font(.system(size: 9))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 4)

                                ScrollView {
                                    VStack(spacing: 2) {
                                        ForEach(tomorrowsProblems) { problem in
                                            TomorrowProblemRow(problem: problem)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                }
                                .frame(maxHeight: 100)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.12, green: 0.11, blue: 0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ProblemRowWidget: View {
    let problem: Problem
    let isCompleted: Bool
    let onRefresh: () -> Void  // Trigger LeetCode sync instead of manual toggle

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            // Status indicator (driven by LeetCode sync)
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14))
                .foregroundColor(isCompleted ? .green : .gray.opacity(0.5))

            // Problem name - clickable link
            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text(problem.name)
                    .font(.system(size: 11))
                    .foregroundColor(isCompleted ? .gray : .white.opacity(0.9))
                    .strikethrough(isCompleted, color: .gray)
                    .lineLimit(1)
                    .underline(isHovering)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()

            // Difficulty badge
            Text(problem.difficulty.rawValue)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(problem.difficulty == .easy ? .green : .orange)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.2))
                )

            // Open link button
            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 10))
                    .foregroundColor(.blue.opacity(0.7))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovering ? Color.white.opacity(0.05) : Color.clear)
        )
    }
}

struct HabitToggle: View {
    let label: String
    let icon: String
    let done: Bool
    let onToggle: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Image(systemName: done ? "checkmark.circle.fill" : icon)
                    .font(.system(size: 10))
                    .foregroundColor(done ? .green : .gray)

                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(done ? .green : .gray)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(done ? Color.green.opacity(0.15) : Color.white.opacity(isHovering ? 0.1 : 0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(done ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

// Carryover problem row (unsolved from today)
struct CarryoverProblemRow: View {
    let problem: Problem
    let onToggle: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            // Checkbox to mark as complete
            Button(action: onToggle) {
                Image(systemName: "circle")
                    .font(.system(size: 12))
                    .foregroundColor(.orange.opacity(0.6))
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            // Problem name - clickable link
            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text(problem.name)
                    .font(.system(size: 10))
                    .foregroundColor(.orange.opacity(0.9))
                    .lineLimit(1)
                    .underline(isHovering)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()

            // Difficulty badge
            Text(problem.difficulty.rawValue)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(problem.difficulty == .easy ? .green : .orange)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.2))
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.orange.opacity(isHovering ? 0.15 : 0.08))
        )
    }
}

// Tomorrow's problem row (preview only)
struct TomorrowProblemRow: View {
    let problem: Problem

    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 8) {
            // Circle indicator (not checkable)
            Image(systemName: "circle.dashed")
                .font(.system(size: 12))
                .foregroundColor(.gray.opacity(0.4))

            // Problem name - clickable link
            Button(action: {
                if let url = URL(string: problem.url) {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Text(problem.name)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                    .underline(isHovering)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }

            Spacer()

            // Difficulty badge
            Text(problem.difficulty.rawValue)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(problem.difficulty == .easy ? .green.opacity(0.6) : .orange.opacity(0.6))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill((problem.difficulty == .easy ? Color.green : Color.orange).opacity(0.1))
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(isHovering ? Color.white.opacity(0.05) : Color.clear)
        )
    }
}
