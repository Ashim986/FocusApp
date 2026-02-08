#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension DebugLogView {
    var content: some View {
        let filtered = filteredEntries
        return Group {
            if filtered.isEmpty {
                VStack(spacing: DSLayout.spacing(8)) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundColor(theme.colors.textSecondary)
                    if store.entries.isEmpty {
                        Text(L10n.Debug.emptyTitle)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                        Text(L10n.Debug.emptyBody)
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)
                    } else {
                        Text("No logs match your filters")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.colors.textPrimary)
                        Text("Try clearing the filters to view recent entries.")
                            .font(.system(size: 12))
                            .foregroundColor(theme.colors.textSecondary)

                        DSButton("Reset filters") {
                            resetFilters()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, DSLayout.spacing(6))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.colors.surface)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DSLayout.spacing(10)) {
                        ForEach(filtered) { entry in
                            DebugLogRow(entry: entry)
                        }
                    }
                    .padding(DSLayout.spacing(12))
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

#endif
