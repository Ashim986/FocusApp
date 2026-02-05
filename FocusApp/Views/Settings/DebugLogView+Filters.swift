import SwiftUI

extension DebugLogView {
    var filters: some View {
        VStack(spacing: 12) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    levelSegmentedPicker
                    categorySegmentedPicker
                }

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        levelMenuPicker
                        categoryMenuPicker
                    }
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.appGray400)
                TextField(L10n.Debug.searchPlaceholder, text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.appGray900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.appGray700, lineWidth: 1)
                    )
            )
        }
        .padding(16)
        .background(Color.appGray800)
    }

    private var levelSegmentedPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var categorySegmentedPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var levelMenuPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }

    private var categoryMenuPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }
}
