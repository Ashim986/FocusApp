import SwiftUI

struct FocusOverlay: View {
    @Binding var isPresented: Bool
    @State private var duration: Int = 180 // minutes
    @State private var timeRemaining: Int = 0
    @State private var totalTime: Int = 0
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isCompleted = false
    @State private var hasStarted = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }

    private var timeString: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        ZStack {
            // Dark background
            Color.appIndigo
                .ignoresSafeArea()

            if !hasStarted {
                // Duration selection
                durationSelector
            } else if isCompleted {
                // Completion screen
                completionView
            } else {
                // Timer view
                timerView
            }
        }
        .onReceive(timer) { _ in
            if isRunning && !isPaused && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 && hasStarted && !isCompleted {
                isCompleted = true
                isRunning = false
            }
        }
    }

    private var durationSelector: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color.appPurple)

                Text("Focus Mode")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("How long do you want to focus?")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }

            // Duration picker
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    durationButton(minutes: 30)
                    durationButton(minutes: 60)
                    durationButton(minutes: 90)
                }

                HStack(spacing: 20) {
                    durationButton(minutes: 120)
                    durationButton(minutes: 180)
                    durationButton(minutes: 240)
                }
            }

            // Custom duration input
            HStack(spacing: 12) {
                Text("Custom:")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))

                TextField("", value: $duration, format: .number)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )

                Text("minutes")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            // Start button
            Button(action: startTimer) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Start Focus Session")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appPurple)
                )
            }
            .buttonStyle(.plain)

            // Cancel button
            Button(action: { isPresented = false }) {
                Text("Cancel")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
    }

    private func durationButton(minutes: Int) -> some View {
        Button(action: { duration = minutes }) {
            Text("\(minutes) min")
                .font(.system(size: 14, weight: duration == minutes ? .semibold : .regular))
                .foregroundColor(duration == minutes ? Color.appPurple : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(duration == minutes ? Color.white : Color.white.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    private var timerView: some View {
        VStack(spacing: 40) {
            // Timer ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 280, height: 280)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.appPurple, Color(hex: "#8b5cf6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)

                // Time display
                VStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text(isPaused ? "Paused" : "Remaining")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Status text
            Text("Stay focused!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            // Control buttons
            HStack(spacing: 20) {
                // Pause/Resume
                Button(action: {
                    isPaused.toggle()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        Text(isPaused ? "Resume" : "Pause")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.15))
                    )
                }
                .buttonStyle(.plain)

                // End session
                Button(action: {
                    isPresented = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                        Text("End Session")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.appRed)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color.appRed.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var completionView: some View {
        VStack(spacing: 32) {
            // Celebration icon
            ZStack {
                Circle()
                    .fill(Color.appGreen.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color.appGreen)
            }

            VStack(spacing: 8) {
                Text("Session Complete!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                Text("Great job staying focused!")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }

            // Stats
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(totalTime / 60)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.appPurple)
                    Text("minutes focused")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Done button
            Button(action: { isPresented = false }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                    Text("Done")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appGreen)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func startTimer() {
        totalTime = duration * 60
        timeRemaining = totalTime
        hasStarted = true
        isRunning = true
    }
}

#Preview {
    FocusOverlay(isPresented: .constant(true))
}
