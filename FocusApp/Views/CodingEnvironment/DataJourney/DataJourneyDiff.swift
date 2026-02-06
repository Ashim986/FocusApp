import Foundation

/// Utilities for computing diffs between consecutive DataJourneyEvents.
/// Used to highlight what changed between steps in the data journey visualization.
enum TraceValueDiff {

    /// Returns the set of variable keys whose values differ between two events.
    static func changedKeys(
        previous: DataJourneyEvent?,
        current: DataJourneyEvent?
    ) -> Set<String> {
        guard let previous, let current else { return current.map { Set($0.values.keys) } ?? [] }
        var changed = Set<String>()
        let allKeys = Set(previous.values.keys).union(current.values.keys)
        for key in allKeys {
            let prevValue = previous.values[key]
            let currValue = current.values[key]
            if prevValue != currValue {
                changed.insert(key)
            }
        }
        return changed
    }

    /// Returns the set of array indices that differ between two TraceValue arrays.
    static func changedIndices(
        previous: TraceValue?,
        current: TraceValue?
    ) -> Set<Int> {
        let prevItems = arrayItems(from: previous)
        let currItems = arrayItems(from: current)
        var changed = Set<Int>()
        let maxCount = max(prevItems.count, currItems.count)
        for index in 0..<maxCount {
            let prev = index < prevItems.count ? prevItems[index] : nil
            let curr = index < currItems.count ? currItems[index] : nil
            if prev != curr {
                changed.insert(index)
            }
        }
        return changed
    }

    /// Returns the set of node IDs that differ between two TraceValue lists.
    static func changedNodeIds(
        previous: TraceValue?,
        current: TraceValue?
    ) -> Set<String> {
        let prevNodes = listNodes(from: previous)
        let currNodes = listNodes(from: current)
        var changed = Set<String>()
        let prevById = Dictionary(uniqueKeysWithValues: prevNodes.map { ($0.id, $0.value) })
        let currById = Dictionary(uniqueKeysWithValues: currNodes.map { ($0.id, $0.value) })
        let allIds = Set(prevById.keys).union(currById.keys)
        for nodeId in allIds {
            if prevById[nodeId] != currById[nodeId] {
                changed.insert(nodeId)
            }
        }
        return changed
    }

    /// Returns the set of tree node IDs that differ between two events.
    static func changedTreeNodeIds(
        previous: TraceValue?,
        current: TraceValue?
    ) -> Set<String> {
        let prevNodes = treeNodes(from: previous)
        let currNodes = treeNodes(from: current)
        var changed = Set<String>()
        let prevById = Dictionary(
            uniqueKeysWithValues: prevNodes.map { ($0.id, $0) }
        )
        let currById = Dictionary(
            uniqueKeysWithValues: currNodes.map { ($0.id, $0) }
        )
        let allIds = Set(prevById.keys).union(currById.keys)
        for nodeId in allIds {
            if prevById[nodeId] != currById[nodeId] {
                changed.insert(nodeId)
            }
        }
        return changed
    }

    /// Returns the set of matrix cell coordinates (row, col) that differ
    /// between two 2D arrays.
    static func changedMatrixCells(
        previous: TraceValue?,
        current: TraceValue?
    ) -> Set<MatrixCell> {
        let prevGrid = matrixRows(from: previous)
        let currGrid = matrixRows(from: current)
        var changed = Set<MatrixCell>()
        let maxRows = max(prevGrid.count, currGrid.count)
        for row in 0..<maxRows {
            let prevRow = row < prevGrid.count ? prevGrid[row] : []
            let currRow = row < currGrid.count ? currGrid[row] : []
            let maxCols = max(prevRow.count, currRow.count)
            for col in 0..<maxCols {
                let prev = col < prevRow.count ? prevRow[col] : nil
                let curr = col < currRow.count ? currRow[col] : nil
                if prev != curr {
                    changed.insert(MatrixCell(row: row, col: col))
                }
            }
        }
        return changed
    }

    /// Returns the set of dictionary keys whose values differ.
    static func changedDictKeys(
        previous: TraceValue?,
        current: TraceValue?
    ) -> Set<String> {
        let prevEntries = dictEntries(from: previous)
        let currEntries = dictEntries(from: current)
        var changed = Set<String>()
        let allKeys = Set(prevEntries.keys).union(currEntries.keys)
        for key in allKeys {
            if prevEntries[key] != currEntries[key] {
                changed.insert(key)
            }
        }
        return changed
    }

    // MARK: - Helpers

    private static func arrayItems(from value: TraceValue?) -> [TraceValue] {
        guard let value else { return [] }
        switch value {
        case .array(let items):
            return items
        case .typed(_, let inner):
            return arrayItems(from: inner)
        default:
            return []
        }
    }

    private static func listNodes(from value: TraceValue?) -> [TraceListNode] {
        guard let value else { return [] }
        switch value {
        case .list(let list):
            return list.nodes
        case .typed(_, let inner):
            return listNodes(from: inner)
        default:
            return []
        }
    }

    private static func treeNodes(from value: TraceValue?) -> [TraceTreeNode] {
        guard let value else { return [] }
        switch value {
        case .tree(let tree):
            return tree.nodes
        case .typed(_, let inner):
            return treeNodes(from: inner)
        default:
            return []
        }
    }

    private static func matrixRows(from value: TraceValue?) -> [[TraceValue]] {
        guard let value else { return [] }
        switch value {
        case .array(let items):
            return items.compactMap { item in
                if case .array(let row) = item { return row }
                return nil
            }
        case .typed(_, let inner):
            return matrixRows(from: inner)
        default:
            return []
        }
    }

    private static func dictEntries(
        from value: TraceValue?
    ) -> [String: TraceValue] {
        guard let value else { return [:] }
        switch value {
        case .object(let map):
            return map
        case .typed(_, let inner):
            return dictEntries(from: inner)
        default:
            return [:]
        }
    }
}

/// Hashable cell coordinate for matrix diff tracking.
struct MatrixCell: Hashable {
    let row: Int
    let col: Int
}
