// iPadCodingView.swift
// FocusApp — iPad Coding Environment (three-panel layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.5

import SwiftUI
import FocusDesignSystem

struct iPadCodingView: View {
    @State private var searchText = ""
    @State private var selectedProblem: String?

    var body: some View {
        HStack(spacing: 0) {
            // Left panel: Problem list (220px)
            VStack(alignment: .leading, spacing: 0) {
                Text("Coding Environment")
                    .font(DSMobileTypography.bodyStrong)
                    .foregroundColor(DSMobileColor.textPrimary)
                    .padding(DSLayout.spacing(.space12))

                DSSearchBar(text: $searchText)
                    .padding(.horizontal, DSLayout.spacing(.space12))
                    .padding(.bottom, DSLayout.spacing(.space8))

                ScrollView {
                    VStack(spacing: DSLayout.spacing(.space8)) {
                        iPadProblemRow(
                            title: "Two Sum",
                            difficulty: "Easy",
                            isSolved: true,
                            isSelected: selectedProblem == "Two Sum"
                        ) { selectedProblem = "Two Sum" }

                        iPadProblemRow(
                            title: "Add Two Numbers",
                            difficulty: "Medium",
                            isSolved: false,
                            isSelected: selectedProblem == "Add Two Numbers"
                        ) { selectedProblem = "Add Two Numbers" }

                        iPadProblemRow(
                            title: "Longest Substring",
                            difficulty: "Medium",
                            isSolved: false,
                            isSelected: selectedProblem == "Longest Substring"
                        ) { selectedProblem = "Longest Substring" }
                    }
                    .padding(.horizontal, DSLayout.spacing(.space12))
                }
            }
            .frame(width: 220)
            .background(DSMobileColor.surface)
            .overlay(alignment: .trailing) {
                Rectangle().fill(DSMobileColor.divider).frame(width: 1)
            }

            // Center panel: Content area
            VStack(alignment: .leading, spacing: 0) {
                // Top bar with Run button
                HStack {
                    Spacer()
                    Button {
                    } label: {
                        HStack(spacing: DSLayout.spacing(.space4)) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            Text("Run")
                                .font(DSMobileTypography.subbodyStrong)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, DSLayout.spacing(.space16))
                        .frame(height: 36)
                        .background(DSMobileColor.purple)
                        .cornerRadius(DSMobileRadius.small)
                    }
                    .buttonStyle(.plain)
                }
                .padding(DSLayout.spacing(.space12))

                if selectedProblem != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                            Text(selectedProblem ?? "")
                                .font(DSMobileTypography.section)
                                .foregroundColor(DSMobileColor.textPrimary)

                            Text("Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.")
                                .font(DSMobileTypography.body)
                                .foregroundColor(DSMobileColor.gray700)
                        }
                        .padding(DSLayout.spacing(.space16))
                    }
                } else {
                    Spacer()
                    Text("Select a problem")
                        .font(DSMobileTypography.body)
                        .foregroundColor(DSMobileColor.gray400)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }

                // Bottom description section
                Divider()
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                    Text("DESCRIPTION")
                        .font(DSMobileTypography.captionStrong)
                        .foregroundColor(DSMobileColor.gray400)
                        .textCase(.uppercase)

                    Text(selectedProblem == nil
                        ? "No problem selected."
                        : "Problem description shown above.")
                        .font(DSMobileTypography.body)
                        .foregroundColor(DSMobileColor.gray400)
                }
                .padding(DSLayout.spacing(.space12))
            }
            .background(DSMobileColor.background)

            // Right panel: Output (140px)
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space8)) {
                Text("OUTPUT / TEST CASES")
                    .font(DSMobileTypography.captionStrong)
                    .foregroundColor(DSMobileColor.gray400)
                    .textCase(.uppercase)

                Text("Case 1")
                    .font(DSMobileTypography.subbodyStrong)
                    .foregroundColor(DSMobileColor.textPrimary)

                // Input block
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text("Input:")
                        .font(DSMobileTypography.captionStrong)
                        .foregroundColor(DSMobileColor.gray500)
                    Text("nums = [2,7,11,15]\ntarget = 9")
                        .font(DSMobileTypography.code)
                        .foregroundColor(DSMobileColor.gray300)
                        .padding(DSLayout.spacing(.space8))
                        .background(DSMobileColor.gray800)
                        .cornerRadius(DSMobileRadius.small)
                }

                Text("Output: [0,1]")
                    .font(DSMobileTypography.code)
                    .foregroundColor(DSMobileColor.textPrimary)

                Divider()

                Text("Console")
                    .font(DSMobileTypography.captionStrong)
                    .foregroundColor(DSMobileColor.gray400)

                Text("No output yet...")
                    .font(DSMobileTypography.code)
                    .foregroundColor(DSMobileColor.gray400)
                    .italic()

                Spacer()
            }
            .padding(DSLayout.spacing(.space12))
            .frame(width: 140)
            .background(DSMobileColor.surface)
            .overlay(alignment: .leading) {
                Rectangle().fill(DSMobileColor.divider).frame(width: 1)
            }
        }
    }
}

struct iPadProblemRow: View {
    var title: String
    var difficulty: String
    var isSolved: Bool
    var isSelected: Bool = false
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSLayout.spacing(.space8)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                    Text(title)
                        .font(DSMobileTypography.subbodyStrong)
                        .foregroundColor(DSMobileColor.gray900)

                    Text(difficulty)
                        .font(DSMobileTypography.caption)
                        .foregroundColor(DSMobileColor.gray500)
                }

                Spacer()

                if isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DSMobileColor.green)
                        .font(.system(size: 16))
                } else {
                    Circle()
                        .stroke(DSMobileColor.gray300, lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(DSLayout.spacing(.space8))
            .background(isSelected ? DSMobileColor.purple.opacity(0.08) : Color.clear)
            .cornerRadius(DSMobileRadius.small)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    iPadCodingView()
        .frame(width: 574, height: 800)
}
