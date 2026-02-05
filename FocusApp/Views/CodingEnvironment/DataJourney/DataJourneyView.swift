import SwiftUI

struct DataJourneyView: View {
    let events: [DataJourneyEvent]
    @Binding var selectedEventID: UUID?
    let onSelectEvent: (DataJourneyEvent) -> Void
    let isTruncated: Bool
    @State var isPlaying = false
    @State var playbackSpeed = 1.0
    @State var playbackTask: Task<Void, Never>?

    var body: some View {
        if events.isEmpty || hasNoData {
            emptyState
        } else {
            content
        }
    }
}
