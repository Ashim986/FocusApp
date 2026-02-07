// iPhoneCodingListView.swift
// FocusApp — iPhone Coding Problem List screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.8

import SwiftUI

struct iPhoneCodingListView: View {
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            LegacyDSHeaderBar()

            ScrollView {
                VStack(spacing: DSLayout.spacing(.space12)) {
                    // Search bar
                    LegacyDSSearchBar(text: $searchText)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // Problem cards
                    LegacyDSProblemCard(
                        title: "Two Sum",
                        difficulty: .easy,
                        isSolved: true
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    LegacyDSProblemCard(
                        title: "Add Two Numbers",
                        difficulty: .medium,
                        isSolved: false
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    LegacyDSProblemCard(
                        title: "Longest Substring Without Repeating Characters",
                        difficulty: .medium,
                        isSolved: false
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    LegacyDSProblemCard(
                        title: "Median of Two Sorted Arrays",
                        difficulty: .hard,
                        isSolved: false
                    )
                    .padding(.horizontal, DSLayout.spacing(.space16))
                }
                .padding(.top, DSLayout.spacing(.space8))
                .padding(.bottom, DSLayout.spacing(.space32))
            }
        }
        .background(LegacyDSColor.background)
    }
}

#Preview {
    iPhoneCodingListView()
}
