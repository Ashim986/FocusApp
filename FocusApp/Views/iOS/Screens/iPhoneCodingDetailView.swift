// iPhoneCodingDetailView.swift
// FocusApp — iPhone Coding Problem Detail screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.9, §4.10, §4.11

import SwiftUI

enum LegacyCodingDetailTab: String, CaseIterable {
    case desc = "Desc"
    case solution = "Solution"
    case code = "Code"
}

struct iPhoneCodingDetailView: View {
    var problemTitle: String = "Two Sum"
    var difficulty: LegacyTaskRowDifficulty = .easy
    @State private var selectedTab: LegacyCodingDetailTab = .desc
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            LegacyDSHeaderBar()

            // Back row
            HStack(spacing: DSLayout.spacing(.space8)) {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(LegacyDSColor.textPrimary)
                }
                .buttonStyle(.plain)

                Text(problemTitle)
                    .font(LegacyDSTypography.section)
                    .foregroundColor(LegacyDSColor.textPrimary)

                Spacer()
            }
            .padding(.horizontal, DSLayout.spacing(.space16))
            .frame(height: 44)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(LegacyCodingDetailTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(LegacyDSTypography.subbodyStrong)
                                .foregroundColor(
                                    selectedTab == tab ? LegacyDSColor.purple : LegacyDSColor.gray500
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)

                            Rectangle()
                                .fill(selectedTab == tab ? LegacyDSColor.purple : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(LegacyDSColor.divider)
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
        .background(LegacyDSColor.background)
    }

    // MARK: - Tab Content

    private var descriptionContent: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
            Text(problemTitle)
                .font(LegacyDSTypography.section)
                .foregroundColor(LegacyDSColor.textPrimary)

            LegacyDSDifficultyBadge(difficulty: difficulty)

            Text("""
            Given an array of integers nums and an integer target, return indices of the two numbers \
            such that they add up to target.

            You may assume that each input would have exactly one solution, and you may not use the \
            same element twice.

            You can return the answer in any order.
            """)
                .font(LegacyDSTypography.body)
                .foregroundColor(LegacyDSColor.gray700)
                .lineSpacing(4)
        }
        .padding(DSLayout.spacing(.space16))
    }

    private var solutionContent: some View {
        VStack {
            Text("Solution content would go here...")
                .font(LegacyDSTypography.body)
                .foregroundColor(LegacyDSColor.gray400)
                .italic()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(DSLayout.spacing(.space16))
        }
    }

    private var codeContent: some View {
        LegacyDSCodeViewer()
            .padding(DSLayout.spacing(.space16))
    }
}

#Preview {
    iPhoneCodingDetailView()
}
