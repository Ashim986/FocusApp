// iPadCodingView.swift
// FocusApp — iPad Coding Environment (three-panel layout)
// Spec: FIGMA_SETUP_GUIDE.md §5.5

import SwiftUI

struct iPadCodingView: View {
    @State private var searchText = ""
    @State private var selectedProblem: String?

    var body: some View {
        HStack(spacing: 0) {
            // Left panel: Problem list (220px)
            VStack(alignment: .leading, spacing: 0) {
                Text("Coding Environment")
                    .font(DSTypography.bodyStrong)
                    .foregroundColor(DSColor.textPrimary)
                    .padding(DSSpacing.space12)

                DSSearchBar(text: $searchText)
                    .padding(.horizontal, DSSpacing.space12)
                    .padding(.bottom, DSSpacing.space8)

                ScrollView {
                    VStack(spacing: DSSpacing.space8) {
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
                    .padding(.horizontal, DSSpacing.space12)
                }
            }
            .frame(width: 220)
            .background(DSColor.surface)
            .overlay(alignment: .trailing) {
                Rectangle().fill(DSColor.divider).frame(width: 1)
            }

            // Center panel: Content area
            VStack(alignment: .leading, spacing: 0) {
                // Top bar with Run button
                HStack {
                    Spacer()
                    Button {
                    } label: {
                        HStack(spacing: DSSpacing.space4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            Text("Run")
                                .font(DSTypography.subbodyStrong)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, DSSpacing.space16)
                        .frame(height: 36)
                        .background(DSColor.purple)
                        .cornerRadius(DSRadius.small)
                    }
                    .buttonStyle(.plain)
                }
                .padding(DSSpacing.space12)

                if selectedProblem != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: DSSpacing.space12) {
                            Text(selectedProblem ?? "")
                                .font(DSTypography.section)
                                .foregroundColor(DSColor.textPrimary)

                            Text("Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.")
                                .font(DSTypography.body)
                                .foregroundColor(DSColor.gray700)
                        }
                        .padding(DSSpacing.space16)
                    }
                } else {
                    Spacer()
                    Text("Select a problem")
                        .font(DSTypography.body)
                        .foregroundColor(DSColor.gray400)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }

                // Bottom description section
                Divider()
                VStack(alignment: .leading, spacing: DSSpacing.space8) {
                    Text("DESCRIPTION")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray400)
                        .textCase(.uppercase)

                    Text(selectedProblem == nil
                        ? "No problem selected."
                        : "Problem description shown above.")
                        .font(DSTypography.body)
                        .foregroundColor(DSColor.gray400)
                }
                .padding(DSSpacing.space12)
            }
            .background(DSColor.background)

            // Right panel: Output (140px)
            VStack(alignment: .leading, spacing: DSSpacing.space8) {
                Text("OUTPUT / TEST CASES")
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray400)
                    .textCase(.uppercase)

                Text("Case 1")
                    .font(DSTypography.subbodyStrong)
                    .foregroundColor(DSColor.textPrimary)

                // Input block
                VStack(alignment: .leading, spacing: DSSpacing.space4) {
                    Text("Input:")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray500)
                    Text("nums = [2,7,11,15]\ntarget = 9")
                        .font(DSTypography.code)
                        .foregroundColor(DSColor.gray300)
                        .padding(DSSpacing.space8)
                        .background(DSColor.gray800)
                        .cornerRadius(DSRadius.small)
                }

                Text("Output: [0,1]")
                    .font(DSTypography.code)
                    .foregroundColor(DSColor.textPrimary)

                Divider()

                Text("Console")
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray400)

                Text("No output yet...")
                    .font(DSTypography.code)
                    .foregroundColor(DSColor.gray400)
                    .italic()

                Spacer()
            }
            .padding(DSSpacing.space12)
            .frame(width: 140)
            .background(DSColor.surface)
            .overlay(alignment: .leading) {
                Rectangle().fill(DSColor.divider).frame(width: 1)
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
            HStack(spacing: DSSpacing.space8) {
                VStack(alignment: .leading, spacing: DSSpacing.space2) {
                    Text(title)
                        .font(DSTypography.subbodyStrong)
                        .foregroundColor(DSColor.gray900)

                    Text(difficulty)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.gray500)
                }

                Spacer()

                if isSolved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(DSColor.green)
                        .font(.system(size: 16))
                } else {
                    Circle()
                        .stroke(DSColor.gray300, lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(DSSpacing.space8)
            .background(isSelected ? DSColor.purple.opacity(0.08) : Color.clear)
            .cornerRadius(DSRadius.small)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    iPadCodingView()
        .frame(width: 574, height: 800)
}
