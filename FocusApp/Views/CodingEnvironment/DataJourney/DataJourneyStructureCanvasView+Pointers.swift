import SwiftUI

extension DataJourneyStructureCanvasView {
    var pointerMarkers: [PointerMarker] {
        guard let selectedEvent, let structure else { return [] }
        switch structure {
        case .list(let list):
            return listPointers(in: selectedEvent, list: list)
        case .listGroup:
            return []
        case .listArray(let listArray):
            return listArrayHeadPointers(for: listArray)
        case .tree:
            return treePointers(in: selectedEvent)
        case .array(let items):
            return arrayPointers(in: selectedEvent, items: items)
        case .graph(let adjacency):
            return graphPointers(in: selectedEvent, adjacency: adjacency)
        case .dictionary(let entries):
            return dictionaryPointers(in: selectedEvent, entries: entries)
        }
    }

    func pointerMarkers(for list: TraceList) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        return listPointers(in: selectedEvent, list: list)
    }

    func arrayPointerMarkers(for items: [TraceValue]) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        return arrayPointers(in: selectedEvent, items: items)
    }

    func listArrayHeadPointers(for listArray: ListArrayStructure) -> [PointerMarker] {
        let indexMarkers = arrayPointerMarkers(for: listArray.heads)
        let headMarkers = listHeadPointers(for: listArray)
        return uniquePointerMarkers(indexMarkers + headMarkers)
    }

    func listHeadPointers(for listArray: ListArrayStructure) -> [PointerMarker] {
        guard let selectedEvent else { return [] }
        var headIdToIndex: [String: Int] = [:]
        for (index, entry) in listArray.lists.enumerated() {
            if let headId = entry.list.nodes.first?.id {
                headIdToIndex[headId] = index
            }
        }
        return pointerCandidates(in: selectedEvent).compactMap { name, value in
            guard case .listPointer(let id) = value,
                  let index = headIdToIndex[id] else { return nil }
            return PointerMarker(name: name, index: index)
        }
    }

    func uniquePointerMarkers(_ markers: [PointerMarker]) -> [PointerMarker] {
        var seen: Set<String> = []
        let unique = markers.filter { marker in
            seen.insert(marker.id).inserted
        }
        return unique.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func pointerCandidates(in event: DataJourneyEvent) -> [(name: String, value: TraceValue)] {
        var result: [(name: String, value: TraceValue)] = []
        for key in event.values.keys.sorted() {
            guard let value = event.values[key] else { continue }
            collectPointerCandidates(path: key, value: value, into: &result)
        }
        return result
    }

    func collectPointerCandidates(
        path: String,
        value: TraceValue,
        into result: inout [(name: String, value: TraceValue)]
    ) {
        switch value {
        case .listPointer, .treePointer:
            result.append((path, value))
        case .object(let map):
            for key in map.keys.sorted() {
                guard let nested = map[key] else { continue }
                collectPointerCandidates(path: "\(path).\(key)", value: nested, into: &result)
            }
        case .array(let items):
            for (index, nested) in items.enumerated() {
                collectPointerCandidates(path: "\(path)[\(index)]", value: nested, into: &result)
            }
        case .typed(_, let inner):
            collectPointerCandidates(path: path, value: inner, into: &result)
        default:
            break
        }
    }

    func listPointerMotions(
        from previousEvent: DataJourneyEvent?,
        to currentEvent: DataJourneyEvent?,
        list: TraceList
    ) -> [PointerMotion] {
        guard let previousEvent, let currentEvent else { return [] }
        let previous = listPointerIndices(in: previousEvent, list: list)
        let current = listPointerIndices(in: currentEvent, list: list)
        return pointerMotions(from: previous, to: current)
    }

    func combinedPointerMotions(
        from previousEvent: DataJourneyEvent?,
        to currentEvent: DataJourneyEvent?,
        lists: [NamedTraceList]
    ) -> [PointerMotion] {
        guard let previousEvent, let currentEvent else { return [] }
        let previous = combinedPointerIndices(in: previousEvent, lists: lists)
        let current = combinedPointerIndices(in: currentEvent, lists: lists)
        return pointerMotions(from: previous, to: current)
    }

    func pointerMotions(
        from previous: [String: Int],
        to current: [String: Int]
    ) -> [PointerMotion] {
        var motions: [PointerMotion] = []
        for (name, toIndex) in current {
            guard let fromIndex = previous[name], fromIndex != toIndex else { continue }
            motions.append(PointerMotion(name: name, fromIndex: fromIndex, toIndex: toIndex))
        }
        return motions.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func listPointerIndices(in event: DataJourneyEvent, list: TraceList) -> [String: Int] {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        var indices: [String: Int] = [:]
        for candidate in pointerCandidates(in: event) {
            guard case .listPointer(let id) = candidate.value,
                  let index = idToIndex[id] else { continue }
            indices[candidate.name] = index
        }
        return indices
    }

    func combinedPointerIndices(in event: DataJourneyEvent, lists: [NamedTraceList]) -> [String: Int] {
        let candidates = pointerCandidates(in: event)
        var indices: [String: Int] = [:]
        var offset = 0
        for entry in lists {
            var idToIndex: [String: Int] = [:]
            for (index, node) in entry.list.nodes.enumerated() {
                idToIndex[node.id] = index
            }
            for candidate in candidates {
                guard case .listPointer(let id) = candidate.value,
                      let index = idToIndex[id] else { continue }
                indices[candidate.name] = index + offset
            }
            offset += entry.list.nodes.count
        }
        return indices
    }

    func listPointers(in event: DataJourneyEvent, list: TraceList) -> [PointerMarker] {
        var idToIndex: [String: Int] = [:]
        for (index, node) in list.nodes.enumerated() {
            idToIndex[node.id] = index
        }
        return pointerCandidates(in: event).compactMap { name, value in
            guard case .listPointer(let id) = value,
                  let index = idToIndex[id] else { return nil }
            return PointerMarker(name: name, index: index)
        }
    }

    func treePointers(in event: DataJourneyEvent) -> [PointerMarker] {
        pointerCandidates(in: event).compactMap { name, value in
            guard case .treePointer(let id) = value else { return nil }
            return PointerMarker(name: name, nodeId: id)
        }
    }

    func arrayPointers(in event: DataJourneyEvent, items: [TraceValue]) -> [PointerMarker] {
        event.values.compactMap { key, value in
            guard case .number(let number, let isInt) = value, isInt else { return nil }
            let index = Int(number)
            guard items.indices.contains(index), isIndexName(key) else { return nil }
            return PointerMarker(name: key, index: index)
        }
        .sorted { $0.name < $1.name }
    }

    func graphPointers(in event: DataJourneyEvent, adjacency: [[Int]]) -> [PointerMarker] {
        event.values.compactMap { key, value in
            guard case .number(let number, let isInt) = value, isInt else { return nil }
            let index = Int(number)
            guard adjacency.indices.contains(index), isIndexName(key) else { return nil }
            return PointerMarker(name: key, index: index)
        }
        .sorted { $0.name < $1.name }
    }

    func dictionaryPointers(in event: DataJourneyEvent, entries: [DictionaryEntry]) -> [PointerMarker] {
        let keyToIndex = Dictionary(uniqueKeysWithValues: entries.enumerated().map { ($0.element.key, $0.offset) })
        return event.values.compactMap { key, value in
            switch value {
            case .string(let stringValue):
                guard let index = keyToIndex[stringValue] else { return nil }
                return PointerMarker(name: key, index: index)
            case .number(let number, let isInt):
                guard isInt else { return nil }
                let stringValue = "\(Int(number))"
                guard let index = keyToIndex[stringValue] else { return nil }
                return PointerMarker(name: key, index: index)
            default:
                return nil
            }
        }
        .sorted { $0.name < $1.name }
    }

    func isIndexName(_ name: String) -> Bool {
        let lowered = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if lowered.hasSuffix("index") { return true }
        let allowed = ["i", "j", "k", "idx", "index", "left", "right", "mid", "lo", "hi", "start", "end"]
        return allowed.contains(lowered)
    }
}
