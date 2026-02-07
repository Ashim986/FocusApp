import FocusDesignSystem
import SwiftUI

extension DebugLogView {
    var content: some View {
        let filtered = filteredEntries
        return Group {
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    DSImage(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(theme.colors.textSecondary)
                    if store.entries.isEmpty {
                        DSText(L10n.Debug.emptyTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                        DSText(L10n.Debug.emptyBody)
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)
                    } else {
                        DSText("No logs match your filters")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                        DSText("Try clearing the filters to view recent entries.")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)

                        DSButton("Reset filters") {
                            resetFilters()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.colors.surface)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(filtered) { entry in
                            DebugLogRow(entry: entry)
                        }
                    }
                    .padding(12)
                }
                .background(theme.colors.surface)
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
