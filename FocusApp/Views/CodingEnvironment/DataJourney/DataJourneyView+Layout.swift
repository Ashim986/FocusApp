import SwiftUI

extension DataJourneyView {
    var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let input = inputEvent {
                valuesSection(title: "Input", event: input)
            }

            if !playbackEvents.isEmpty {
                stepControls
            }

            DataJourneyStructureCanvasView(
                inputEvent: inputEvent,
                selectedEvent: selectedEvent
            )

            if let selected = selectedEvent {
                valuesSection(title: selectedTitle(for: selected), event: selected)
            }

            if let output = outputEvent {
                valuesSection(title: "Output", event: output)
            }
        }
    }

    var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Run with input to see the data journey.")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.appGray300)
            Text("Add `Trace.step(\"label\", [\"key\": value])` inside loops to visualize iterations.")
                .font(.system(size: 10))
                .foregroundColor(Color.appGray500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func valuesSection(title: String, event: DataJourneyEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.appGray400)

            if event.values.isEmpty {
                Text("No values captured for this step.")
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGray500)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(event.values.keys.sorted(), id: \.self) { key in
                        if let value = event.values[key] {
                            HStack(alignment: .center, spacing: 10) {
                                Text(key)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(Color.appGray300)
                                    .frame(width: 80, alignment: .leading)

                                TraceValueView(value: value)
                            }
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray900.opacity(0.45))
        )
    }
}
