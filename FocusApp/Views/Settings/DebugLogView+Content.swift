import SwiftUI

extension DebugLogView {
    var content: some View {
        let filtered = filteredEntries
        return Group {
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color.appGray500)
                    if store.entries.isEmpty {
                        Text(L10n.Debug.emptyTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(L10n.Debug.emptyBody)
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray500)
                    } else {
                        Text("No logs match your filters")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Try clearing the filters to view recent entries.")
                            .font(.system(size: 12))
                            .foregroundColor(Color.appGray500)

                        Button("Reset filters") {
                            resetFilters()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appGray900)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(filtered) { entry in
                            DebugLogRow(entry: entry)
                        }
                    }
                    .padding(12)
                }
                .background(Color.appGray900)
            }
        }
    }

    var filteredEntries: [DebugLogEntry] {
        store.entries.filter { entry in
            if selectedLevel != .all && entry.level != selectedLevel.level {
                return false
            }
            if selectedCategory != .all && entry.category != selectedCategory.category {
                return false
            }
            if !searchText.isEmpty {
                let haystack = "\(entry.title) \(entry.message) \(entry.metadata.values.joined(separator: " "))"
                if !haystack.lowercased().contains(searchText.lowercased()) {
                    return false
                }
            }
            return true
        }
    }

    private func resetFilters() {
        selectedLevel = .all
        selectedCategory = .all
        searchText = ""
    }
}
