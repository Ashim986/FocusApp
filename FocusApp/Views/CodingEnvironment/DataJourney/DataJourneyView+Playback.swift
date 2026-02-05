import SwiftUI

extension DataJourneyView {
    var stepControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button(action: selectPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(currentPlaybackIndex == 0 ? Color.appGray600 : Color.appGray300)
                .disabled(currentPlaybackIndex == 0)

                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(playbackEvents.count > 1 ? Color.appGray300 : Color.appGray600)
                .disabled(playbackEvents.count <= 1)

                Button(action: selectNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
                .foregroundColor(currentPlaybackIndex >= playbackEvents.count - 1 ? Color.appGray600 : Color.appGray300)
                .disabled(currentPlaybackIndex >= playbackEvents.count - 1)

                Text(stepLabel(for: playbackEvents[currentPlaybackIndex]))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray300)

                Spacer()

                Picker("Speed", selection: $playbackSpeed) {
                    Text("0.5x").tag(0.5)
                    Text("1x").tag(1.0)
                    Text("1.5x").tag(1.5)
                    Text("2x").tag(2.0)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)

                if !isPlaying, currentPlaybackIndex >= playbackEvents.count - 1 {
                    Button(action: { selectIndex(0) }, label: {
                        Text("Start Over")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color.appGray200)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.appGray800)
                            )
                    })
                    .buttonStyle(.plain)
                }
            }

            let sliderBinding = Binding(
                get: { Double(currentPlaybackIndex) },
                set: { selectIndex(Int($0)) }
            )
            let sliderRange = 0...Double(max(playbackEvents.count - 1, 1))
            if playbackEvents.count > 1 {
                Slider(value: sliderBinding, in: sliderRange, step: 1)
                    .tint(Color.appPurple)
            } else {
                Slider(value: sliderBinding, in: sliderRange)
                    .tint(Color.appPurple)
                    .disabled(true)
            }

            if isTruncated {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.appAmber)
                    Text("Showing first 40 steps. Reduce `Trace.step` calls to see more.")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color.appAmber)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(playbackEvents) { event in
                        Button(action: {
                            selectEvent(event)
                        }, label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(event.id == selectedEventID ? Color.appPurple : Color.appGray600)
                                    .frame(width: 6, height: 6)
                                Text(stepLabel(for: event))
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(event.id == selectedEventID ? Color.appPurple.opacity(0.2) : Color.appGray800)
                            )
                        })
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray900.opacity(0.35))
        )
        .onChange(of: isPlaying) { _, playing in
            playbackTask?.cancel()
            guard playing else { return }
            playbackTask = Task {
                await runPlaybackLoop()
            }
        }
        .onChange(of: events.map(\.id)) { _, _ in
            isPlaying = false
            playbackTask?.cancel()
            ensurePlaybackSelection()
        }
        .onAppear {
            ensurePlaybackSelection()
        }
        .onDisappear {
            playbackTask?.cancel()
        }
    }

    func ensurePlaybackSelection() {
        guard !playbackEvents.isEmpty else { return }
        if let selectedEventID,
           playbackEvents.contains(where: { $0.id == selectedEventID }) {
            return
        }
        selectEvent(playbackEvents[0])
    }

    func selectEvent(_ event: DataJourneyEvent) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedEventID = event.id
            onSelectEvent(event)
        }
    }

    func selectIndex(_ index: Int) {
        guard playbackEvents.indices.contains(index) else { return }
        selectEvent(playbackEvents[index])
    }

    func selectPrevious() {
        selectIndex(max(currentPlaybackIndex - 1, 0))
    }

    func selectNext() {
        selectIndex(min(currentPlaybackIndex + 1, playbackEvents.count - 1))
    }

    func togglePlayback() {
        guard playbackEvents.count > 1 else { return }
        if !isPlaying && currentPlaybackIndex >= playbackEvents.count - 1 {
            selectIndex(0)
        }
        isPlaying.toggle()
    }

    @MainActor
    func runPlaybackLoop() async {
        while isPlaying {
            let interval = max(0.2, 1.0 / playbackSpeed)
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            guard isPlaying else { break }
            if currentPlaybackIndex >= playbackEvents.count - 1 {
                isPlaying = false
                break
            }
            selectNext()
        }
    }
}
