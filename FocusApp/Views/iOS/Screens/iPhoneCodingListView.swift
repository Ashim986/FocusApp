// iPhoneCodingListView.swift
// FocusApp — iPhone Coding Problem List screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.8

import SwiftUI

struct iPhoneCodingListView: View {
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            ScrollView {
                VStack(spacing: DSSpacing.space12) {
                    // Search bar
                    DSSearchBar(text: $searchText)
                        .padding(.horizontal, DSSpacing.space16)

                    // Problem cards
                    DSProblemCard(
                        title: "Two Sum",
                        difficulty: .easy,
                        isSolved: true
                    )
                    .padding(.horizontal, DSSpacing.space16)

                    DSProblemCard(
                        title: "Add Two Numbers",
                        difficulty: .medium,
                        isSolved: false
                    )
                    .padding(.horizontal, DSSpacing.space16)

                    DSProblemCard(
                        title: "Longest Substring Without Repeating Characters",
                        difficulty: .medium,
                        isSolved: false
                    )
                    .padding(.horizontal, DSSpacing.space16)

                    DSProblemCard(
                        title: "Median of Two Sorted Arrays",
                        difficulty: .hard,
                        isSolved: false
                    )
                    .padding(.horizontal, DSSpacing.space16)
                }
                .padding(.top, DSSpacing.space8)
                .padding(.bottom, DSSpacing.space32)
            }
        }
        .background(DSColor.background)
    }
}

#Preview {
    iPhoneCodingListView()
}
