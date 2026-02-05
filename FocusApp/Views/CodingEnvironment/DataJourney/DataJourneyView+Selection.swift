import SwiftUI

extension DataJourneyView {
    var inputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .input })
    }

    var outputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .output })
    }

    var stepEvents: [DataJourneyEvent] {
        events.filter { $0.kind == .step }
    }

    var playbackEvents: [DataJourneyEvent] {
        if !stepEvents.isEmpty {
            return stepEvents
        }
        return [inputEvent, outputEvent].compactMap { $0 }
    }

    var selectedEvent: DataJourneyEvent? {
        if let selectedEventID, let event = events.first(where: { $0.id == selectedEventID }) {
            return event
        }
        return stepEvents.first ?? inputEvent ?? outputEvent
    }

    var hasNoData: Bool {
        let hasValues = events.contains { !$0.values.isEmpty }
        return !hasValues
    }

    var currentPlaybackIndex: Int {
        guard !playbackEvents.isEmpty else { return 0 }
        if let selectedEventID,
           let index = playbackEvents.firstIndex(where: { $0.id == selectedEventID }) {
            return index
        }
        return 0
    }

    func stepLabel(for event: DataJourneyEvent) -> String {
        if let label = event.label, !label.isEmpty {
            return label
        }
        let index = stepEvents.firstIndex(where: { $0.id == event.id }) ?? 0
        return "Step \(index + 1)"
    }

    func selectedTitle(for event: DataJourneyEvent) -> String {
        switch event.kind {
        case .input:
            return "Input"
        case .output:
            return "Output"
        case .step:
            return stepLabel(for: event)
        }
    }
}
