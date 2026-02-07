import FocusDesignSystem
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
                DSImage(systemName: "magnifyingglass")
                    .foregroundColor(theme.colors.textSecondary)
                DSTextField(
                    placeholder: L10n.Debug.searchPlaceholder,
                    text: $searchText,
                    config: DSTextFieldConfig(style: .outlined, size: .small)
                )
            }
        }
        .padding(16)
        .background(theme.colors.surfaceElevated)
    }

    private var levelSegmentedPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                DSText(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var categorySegmentedPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                DSText(filter.title).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }

    private var levelMenuPicker: some View {
        Picker(L10n.Debug.levelLabel, selection: $selectedLevel) {
            ForEach(DebugLogLevelFilter.allCases, id: \.self) { filter in
                DSText(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }

    private var categoryMenuPicker: some View {
        Picker(L10n.Debug.categoryLabel, selection: $selectedCategory) {
            ForEach(DebugLogCategoryFilter.allCases, id: \.self) { filter in
                DSText(filter.title).tag(filter)
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity)
    }
}
