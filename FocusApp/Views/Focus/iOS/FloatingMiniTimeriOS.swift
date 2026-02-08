#if os(iOS)
// FloatingMiniTimeriOS.swift
// FocusApp -- Floating mini Pomodoro timer overlay for the coding environment

import FocusDesignSystem
import SwiftUI

struct FloatingMiniTimeriOS: View {
    @Environment(\.dsTheme) var theme

    @ObservedObject var coordinator: FocusCoordinator

    @State private var isExpanded = false
    @State private var offset: CGSize = .zero
    @State private var dragAccumulated: CGSize = .zero

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let collapsedSize: CGFloat = 56
    private let expandedWidth: CGFloat = 200
    private let expandedHeight: CGFloat = 120
    private let purpleAccent = Color(hex: 0x6366F1)

    var body: some View {
        if coordinator.isSessionActive {
            Group {
                if isExpanded {
                    expandedCard
                } else {
                    collapsedBubble
                }
            }
            .offset(x: offset.width, y: offset.height)
            .gesture(dragGesture)
            .onReceive(timer) { _ in
                coordinator.handleTick()
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
        }
    }

    // MARK: - Collapsed State

    private var collapsedBubble: some View {
        Button {
            isExpanded = true
        } label: {
            Text(formattedTime)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: collapsedSize, height: collapsedSize)
                .background(purpleAccent)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Expanded State

    private var expandedCard: some View {
        VStack(spacing: 10) {
            // Time display
            Text(formattedTime)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            // Controls
            HStack(spacing: 12) {
                // Pause / Resume
                Button {
                    if coordinator.presenter.isPaused {
                        coordinator.resume()
                    } else {
                        coordinator.pause()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(
                            systemName: coordinator.presenter.isPaused
                                ? "play.fill" : "pause.fill"
                        )
                        .font(.system(size: 12))
                        Text(coordinator.presenter.isPaused ? "Resume" : "Pause")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(purpleAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)

                // End Session
                Button {
                    coordinator.endSession()
                    isExpanded = false
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 12))
                        Text("End")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: expandedWidth, height: expandedHeight)
        .background(purpleAccent)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        .onTapGesture {
            // Tap the card body to collapse (outside buttons)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isExpanded = false
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
            .padding(8)
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: dragAccumulated.width + value.translation.width,
                    height: dragAccumulated.height + value.translation.height
                )
            }
            .onEnded { value in
                dragAccumulated = CGSize(
                    width: dragAccumulated.width + value.translation.width,
                    height: dragAccumulated.height + value.translation.height
                )
                offset = dragAccumulated
            }
    }

    // MARK: - Helpers

    /// Formats the presenter's time string into a compact "MM:SS" display.
    /// The presenter provides "H:MM:SS"; this strips the leading hour when zero.
    private var formattedTime: String {
        let parts = coordinator.presenter.timeString.split(separator: ":")
        guard parts.count == 3 else { return coordinator.presenter.timeString }

        let hours = Int(parts[0]) ?? 0
        let minutes = String(parts[1])
        let seconds = String(parts[2])

        if hours > 0 {
            return "\(hours):\(minutes):\(seconds)"
        }
        return "\(minutes):\(seconds)"
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        FloatingMiniTimeriOS(coordinator: FocusCoordinator())
            .padding(24)
    }
}
#endif
