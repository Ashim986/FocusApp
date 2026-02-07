import FocusDesignSystem
import SwiftUI

extension DataJourneyView {
    enum StepControlsStyle {
        case standalone
        case embedded
    }

    func stepControls(style: StepControlsStyle = .standalone) -> some View {
        let isEmbedded = style == .embedded
        let iconSize: CGFloat = isEmbedded ? 9 : 10
        let textSize: CGFloat = isEmbedded ? 9 : 10
        let spacing: CGFloat = isEmbedded ? 6 : 8
        let chipFontSize: CGFloat = isEmbedded ? 9 : 10
        let chipVerticalPadding: CGFloat = isEmbedded ? 4 : 6
        let controlPadding: CGFloat = isEmbedded ? 0 : 10
        let pickerWidth: CGFloat = isEmbedded ? 120 : 140
        let sliderHeight: CGFloat = isEmbedded ? 12 : 18

        return VStack(alignment: .leading, spacing: spacing) {
            stepControlsHeader(
                iconSize: iconSize,
                textSize: textSize,
                spacing: spacing,
                pickerWidth: pickerWidth,
                isEmbedded: isEmbedded
            )

            let sliderBinding = Binding(
                get: { Double(currentPlaybackIndex) },
                set: { selectIndex(Int($0)) }
            )
            let sliderRange = 0...Double(max(playbackEvents.count - 1, 1))
            Group {
                if playbackEvents.count > 1 {
                    Slider(value: sliderBinding, in: sliderRange, step: 1)
                        .tint(palette.purple)
                } else {
                    Slider(value: sliderBinding, in: sliderRange)
                        .tint(palette.purple)
                        .disabled(true)
                }
            }
            .frame(height: sliderHeight)

            if isTruncated {
                HStack(spacing: DSLayout.spacing(6)) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: textSize, weight: .semibold))
                        .foregroundColor(palette.amber)
                    Text(truncationMessage)
                        .font(.system(size: isEmbedded ? 8 : 9, weight: .medium))
                        .foregroundColor(palette.amber)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSLayout.spacing(6)) {
                    ForEach(playbackEvents) { event in
                        DSActionButton(action: {
                            selectEvent(event)
                        }) {
                            HStack(spacing: DSLayout.spacing(6)) {
                                Circle()
                                    .fill(event.id == selectedEventID ? palette.purple : palette.gray600)
                                    .frame(width: 6, height: 6)
                                Text(stepLabel(for: event))
                                    .font(.system(size: chipFontSize, weight: .semibold))
                            }
                            .padding(.horizontal, DSLayout.spacing(8))
                            .padding(.vertical, chipVerticalPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(event.id == selectedEventID ? palette.purple.opacity(0.2) : palette.gray800)
                                )
                        }
                    }
                }
                .padding(.horizontal, DSLayout.spacing(2))
            }
        }
        .padding(controlPadding)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isEmbedded ? Color.clear : palette.gray900.opacity(0.35))
        )
    }

    func stepControlsHeader(style: StepControlsStyle = .standalone) -> some View {
        let isEmbedded = style == .embedded
        let iconSize: CGFloat = isEmbedded ? 9 : 10
        let textSize: CGFloat = isEmbedded ? 9 : 10
        let spacing: CGFloat = isEmbedded ? 6 : 8
        let pickerWidth: CGFloat = isEmbedded ? 120 : 140

        return stepControlsHeader(
            iconSize: iconSize,
            textSize: textSize,
            spacing: spacing,
            pickerWidth: pickerWidth,
            isEmbedded: isEmbedded
        )
    }

    func stepControlsTimeline(style: StepControlsStyle = .standalone) -> some View {
        let isEmbedded = style == .embedded
        let textSize: CGFloat = isEmbedded ? 9 : 10
        let chipFontSize: CGFloat = isEmbedded ? 9 : 10
        let chipVerticalPadding: CGFloat = isEmbedded ? 4 : 6
        let sliderHeight: CGFloat = isEmbedded ? 12 : 18

        let sliderBinding = Binding(
            get: { Double(currentPlaybackIndex) },
            set: { selectIndex(Int($0)) }
        )
        let sliderRange = 0...Double(max(playbackEvents.count - 1, 1))

        return VStack(alignment: .leading, spacing: isEmbedded ? 6 : 8) {
            Group {
                if playbackEvents.count > 1 {
                    Slider(value: sliderBinding, in: sliderRange, step: 1)
                        .tint(palette.purple)
                } else {
                    Slider(value: sliderBinding, in: sliderRange)
                        .tint(palette.purple)
                        .disabled(true)
                }
            }
            .frame(height: sliderHeight)

            if isTruncated {
                HStack(spacing: DSLayout.spacing(6)) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: textSize, weight: .semibold))
                        .foregroundColor(palette.amber)
                    Text(truncationMessage)
                        .font(.system(size: isEmbedded ? 8 : 9, weight: .medium))
                        .foregroundColor(palette.amber)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSLayout.spacing(6)) {
                    ForEach(playbackEvents) { event in
                        DSActionButton(action: {
                            selectEvent(event)
                        }) {
                            HStack(spacing: DSLayout.spacing(6)) {
                                Circle()
                                    .fill(event.id == selectedEventID ? palette.purple : palette.gray600)
                                    .frame(width: 6, height: 6)
                                Text(stepLabel(for: event))
                                    .font(.system(size: chipFontSize, weight: .semibold))
                            }
                            .padding(.horizontal, DSLayout.spacing(8))
                            .padding(.vertical, chipVerticalPadding)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(event.id == selectedEventID ? palette.purple.opacity(0.2) : palette.gray800)
                                )
                        }
                    }
                }
                .padding(.horizontal, DSLayout.spacing(2))
            }
        }
    }

    private func stepControlsHeader(
        iconSize: CGFloat,
        textSize: CGFloat,
        spacing: CGFloat,
        pickerWidth: CGFloat,
        isEmbedded: Bool
    ) -> some View {
        HStack(alignment: .center, spacing: spacing) {
            HStack(spacing: DSLayout.spacing(12)) {
                DSActionButton(action: selectPrevious) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: iconSize, weight: .bold))
                }
                .foregroundColor(currentPlaybackIndex == 0 ? palette.gray600 : palette.gray300)
                .disabled(currentPlaybackIndex == 0)

                DSActionButton(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: iconSize, weight: .bold))
                }
                .foregroundColor(playbackEvents.count > 1 ? palette.gray300 : palette.gray600)
                .disabled(playbackEvents.count <= 1)

                DSActionButton(action: selectNext) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: iconSize, weight: .bold))
                }
                .foregroundColor(currentPlaybackIndex >= playbackEvents.count - 1 ? palette.gray600 : palette.gray300)
                .disabled(currentPlaybackIndex >= playbackEvents.count - 1)
            }

            if playbackEvents.indices.contains(currentPlaybackIndex) {
                Text(stepLabel(for: playbackEvents[currentPlaybackIndex]))
                    .font(.system(size: textSize, weight: .semibold))
                    .foregroundColor(palette.gray300)
            }

            Spacer()

            HStack(spacing: DSLayout.spacing(8)) {
                Picker("Speed", selection: $playbackSpeed) {
                    Text("0.5x").tag(0.5)
                    Text("1x").tag(1.0)
                    Text("1.5x").tag(1.5)
                    Text("2x").tag(2.0)
                }
                .pickerStyle(.segmented)
                .frame(width: pickerWidth)

                ZStack {
                    DSButton(
                        "Start Over",
                        config: .init(style: .secondary, size: .small),
                        action: { selectIndex(0) }
                    )
                    .opacity(!isPlaying && currentPlaybackIndex >= playbackEvents.count - 1 ? 1 : 0)
                    .disabled(isPlaying || currentPlaybackIndex < playbackEvents.count - 1)
                }
                .offset(x: 16)
            }
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

    private var truncationMessage: String {
        "Showing first 40 steps or truncated data. " +
        "Reduce `Trace.step` calls or input size to see more."
    }
}
