import SwiftUI

struct DataJourneyView: View {
    let events: [DataJourneyEvent]
    @Binding var selectedEventID: UUID?
    let onSelectEvent: (DataJourneyEvent) -> Void

    var body: some View {
        if events.isEmpty || hasNoData {
            emptyState
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let input = inputEvent {
                valuesSection(title: "Input", event: input)
            }

            if !stepEvents.isEmpty {
                stepSelector
            }

            if let selected = selectedEvent {
                valuesSection(title: selectedTitle(for: selected), event: selected)
            }

            if let output = outputEvent {
                valuesSection(title: "Output", event: output)
            }
        }
    }

    private var emptyState: some View {
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

    private var stepSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(stepEvents) { event in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedEventID = event.id
                            onSelectEvent(event)
                        }
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

    private func valuesSection(title: String, event: DataJourneyEvent) -> some View {
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

    private var inputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .input })
    }

    private var outputEvent: DataJourneyEvent? {
        events.first(where: { $0.kind == .output })
    }

    private var stepEvents: [DataJourneyEvent] {
        events.filter { $0.kind == .step }
    }

    private var selectedEvent: DataJourneyEvent? {
        if let selectedEventID, let event = events.first(where: { $0.id == selectedEventID }) {
            return event
        }
        return stepEvents.first ?? inputEvent ?? outputEvent
    }

    private var hasNoData: Bool {
        let hasValues = events.contains { !$0.values.isEmpty }
        return !hasValues
    }

    private func stepLabel(for event: DataJourneyEvent) -> String {
        if let label = event.label, !label.isEmpty {
            return label
        }
        let index = stepEvents.firstIndex(where: { $0.id == event.id }) ?? 0
        return "Step \(index + 1)"
    }

    private func selectedTitle(for event: DataJourneyEvent) -> String {
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

private struct TraceValueView: View {
    let value: TraceValue

    var body: some View {
        switch value {
        case .null:
            traceCircle("null", fill: Color.appGray700)
        case .bool(let boolValue):
            traceCircle(boolValue ? "true" : "false", fill: Color.appPurple.opacity(0.3))
        case .number(let number, let isInt):
            let text = isInt ? "\(Int(number))" : String(format: "%.2f", number)
            traceCircle(text, fill: Color.appAmber.opacity(0.3))
        case .string(let stringValue):
            traceCircle(stringValue, fill: Color.appGreen.opacity(0.25))
        case .array(let items):
            arrayView(items)
        case .object(let map):
            objectView(map)
        case .typed(let type, let inner):
            typedView(type: type, value: inner)
        }
    }

    private func arrayView(_ items: [TraceValue]) -> some View {
        HStack(spacing: 6) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                TraceValueView(value: item)
            }
        }
    }

    private func objectView(_ map: [String: TraceValue]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(map.keys.sorted(), id: \.self) { key in
                if let value = map[key] {
                    HStack(spacing: 6) {
                        Text(key)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color.appGray400)
                        TraceValueView(value: value)
                    }
                }
            }
        }
    }

    private func typedView(type: String, value: TraceValue) -> some View {
        switch type.lowercased() {
        case "list":
            return AnyView(listView(value))
        case "tree":
            return AnyView(treeView(value))
        default:
            return AnyView(TraceValueView(value: value))
        }
    }

    private func listView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        return AnyView(
            HStack(spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    TraceValueView(value: item)
                    if index < items.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color.appGray500)
                    }
                }
            }
        )
    }

    private func treeView(_ value: TraceValue) -> some View {
        guard case .array(let items) = value else {
            return AnyView(TraceValueView(value: value))
        }
        let levels = treeLevels(from: items)
        return AnyView(
            VStack(spacing: 8) {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                    HStack(spacing: 6) {
                        ForEach(Array(level.enumerated()), id: \.offset) { _, node in
                            if let node {
                                TraceValueView(value: node)
                            } else {
                                traceCircle("•", fill: Color.appGray800)
                                    .opacity(0.4)
                            }
                        }
                    }
                }
            }
        )
    }

    private func treeLevels(from items: [TraceValue]) -> [[TraceValue?]] {
        var levels: [[TraceValue?]] = []
        var index = 0
        var count = 1
        while index < items.count {
            var level: [TraceValue?] = []
            for _ in 0..<count {
                guard index < items.count else { break }
                let item = items[index]
                level.append(item == .null ? nil : item)
                index += 1
            }
            levels.append(level)
            count *= 2
        }
        return levels
    }

    private func traceCircle(_ text: String, fill: Color) -> some View {
        ZStack {
            Circle()
                .fill(fill)
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 4)
        }
        .frame(width: 30, height: 30)
    }
}
