// iPhoneCodingDetailView.swift
// FocusApp — iPhone Coding Problem Detail screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.9, §4.10, §4.11

import SwiftUI

enum CodingDetailTab: String, CaseIterable {
    case desc = "Desc"
    case solution = "Solution"
    case code = "Code"
}

struct iPhoneCodingDetailView: View {
    var problemTitle: String = "Two Sum"
    var difficulty: TaskRowDifficulty = .easy
    @State private var selectedTab: CodingDetailTab = .desc
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            // Back row
            HStack(spacing: DSSpacing.space8) {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DSColor.textPrimary)
                }
                .buttonStyle(.plain)

                Text(problemTitle)
                    .font(DSTypography.section)
                    .foregroundColor(DSColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, DSSpacing.space16)
            .frame(height: 44)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(CodingDetailTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(DSTypography.subbodyStrong)
                                .foregroundColor(
                                    selectedTab == tab ? DSColor.purple : DSColor.gray500
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)

                            Rectangle()
                                .fill(selectedTab == tab ? DSColor.purple : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(DSColor.divider)
                    .frame(height: 1)
            }

            // Content
            ScrollView {
                switch selectedTab {
                case .desc:
                    descriptionContent
                case .solution:
                    solutionContent
                case .code:
                    codeContent
                }
            }
        }
        .background(DSColor.background)
    }

    // MARK: - Tab Content

    private var descriptionContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.space12) {
            Text(problemTitle)
                .font(DSTypography.section)
                .foregroundColor(DSColor.textPrimary)

            DSDifficultyBadge(difficulty: difficulty)

            Text("""
            Given an array of integers nums and an integer target, return indices of the two numbers \
            such that they add up to target.

            You may assume that each input would have exactly one solution, and you may not use the \
            same element twice.

            You can return the answer in any order.
            """)
                .font(DSTypography.body)
                .foregroundColor(DSColor.gray700)
                .lineSpacing(4)
        }
        .padding(DSSpacing.space16)
    }

    private var solutionContent: some View {
        VStack {
            Text("Solution content would go here...")
                .font(DSTypography.body)
                .foregroundColor(DSColor.gray400)
                .italic()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(DSSpacing.space16)
        }
    }

    private var codeContent: some View {
        DSCodeViewer()
            .padding(DSSpacing.space16)
    }
}

#Preview {
    iPhoneCodingDetailView()
}
