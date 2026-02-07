import FocusDesignSystem
import SwiftUI

struct DataJourneyView: View {
    let events: [DataJourneyEvent]
    @Binding var selectedEventID: UUID?
    let onSelectEvent: (DataJourneyEvent) -> Void
    let isTruncated: Bool
    @State var isPlaying = false
    @State var playbackSpeed = 1.0
    @State var playbackTask: Task<Void, Never>?
    @Environment(\.dsTheme) var theme

    var palette: DataJourneyPalette {
        DataJourneyPalette(theme: theme)
    }

    var body: some View {
        if events.isEmpty || hasNoData {
            emptyState
        } else {
            content
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
    }
}
