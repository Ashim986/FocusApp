// iPhoneCodingDetailView.swift
// FocusApp -- iPhone Coding Problem Detail screen (393x852)

import FocusDesignSystem
import SwiftUI

// MARK: - Coding Detail Tab

enum CodingDetailTab: String, CaseIterable {
    case desc = "Desc"
    case solution = "Solution"
    case code = "Code"
}

struct iPhoneCodingDetailView: View {
    @Environment(\.dsTheme) var theme

    var problemTitle: String = "Two Sum"
    var difficulty: TaskDifficulty = .easy
    @State private var selectedTab: CodingDetailTab = .desc
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            // Back row
            HStack(spacing: theme.spacing.sm) {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)
                }
                .buttonStyle(.plain)

                Text(problemTitle)
                    .font(theme.typography.subtitle)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.lg)
            .frame(height: 44)

            // Tab bar
            HStack(spacing: 0) {
                ForEach(CodingDetailTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(theme.typography.body)
                                .fontWeight(.semibold)
                                .foregroundColor(
                                    selectedTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color(hex: 0x6B7280)
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)

                            Rectangle()
                                .fill(
                                    selectedTab == tab
                                        ? Color(hex: 0x6366F1)
                                        : Color.clear
                                )
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.colors.border)
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
        .background(theme.colors.background)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button { } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(theme.colors.textSecondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.trailing, theme.spacing.lg)
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }

    // MARK: - Tab Content

    private var descriptionContent: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text(problemTitle)
                .font(theme.typography.subtitle)
                .foregroundColor(theme.colors.textPrimary)

            // Difficulty badge
            Text(difficulty.rawValue)
                .font(theme.typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(difficulty.textColor)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(difficulty.bgColor)
                .cornerRadius(theme.radii.sm)

            Text("""
            Given an array of integers nums and an integer target, return indices of the two numbers \
            such that they add up to target.

            You may assume that each input would have exactly one solution, and you may not use the \
            same element twice.

            You can return the answer in any order.
            """)
                .font(theme.typography.body)
                .foregroundColor(Color(hex: 0x374151))
                .lineSpacing(4)
        }
        .padding(theme.spacing.lg)
    }

    private var solutionContent: some View {
        VStack {
            Text("Solution content would go here...")
                .font(theme.typography.body)
                .foregroundColor(Color(hex: 0x9CA3AF))
                .italic()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(theme.spacing.lg)
        }
    }

    private var codeContent: some View {
        codeViewer
            .padding(theme.spacing.lg)
    }

    // MARK: - Code Viewer

    private var codeViewer: some View {
        let code = """
        function twoSum(nums: number[], target: number): number[] {
            const map = new Map<number, number>();
            for (let i = 0; i < nums.length; i++) {
                const complement = target - nums[i];
                if (map.has(complement)) {
                    return [map.get(complement)!, i];
                }
                map.set(nums[i], i);
            }
            return [];
        }
        """
        let lines = code.components(separatedBy: "\n")

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("TypeScript")
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: 0x9CA3AF))

                Spacer()

                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                    Text("Read-only")
                        .font(theme.typography.caption)
                }
                .foregroundColor(Color(hex: 0x9CA3AF))
            }
            .padding(theme.spacing.md)

            Divider()
                .background(Color(hex: 0x374151))

            // Code area
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text("\(i + 1)")
                                .font(theme.typography.mono)
                                .foregroundColor(Color(hex: 0x6B7280))
                                .frame(width: 32, alignment: .trailing)
                                .frame(height: 18)
                        }
                    }
                    .padding(.leading, theme.spacing.sm)

                    // Code text
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<lines.count, id: \.self) { i in
                            Text(lines[i])
                                .font(theme.typography.mono)
                                .foregroundColor(Color(hex: 0xD1D5DB))
                                .frame(height: 18, alignment: .leading)
                        }
                    }
                    .padding(.leading, theme.spacing.md)
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .background(Color(hex: 0x1F2937))
        .cornerRadius(theme.radii.md)
    }
}

#Preview {
    iPhoneCodingDetailView()
}
