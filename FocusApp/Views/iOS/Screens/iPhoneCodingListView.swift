// iPhoneCodingListView.swift
// FocusApp -- iPhone Coding Problem List screen (393x852)

import FocusDesignSystem
import SwiftUI

struct iPhoneCodingListView: View {
    @Environment(\.dsTheme) var theme

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(spacing: theme.spacing.md) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, theme.spacing.lg)

                    // Problem cards
                    problemCard(title: "Two Sum", difficulty: .easy, isSolved: true)
                        .padding(.horizontal, theme.spacing.lg)

                    problemCard(title: "Add Two Numbers", difficulty: .medium, isSolved: false)
                        .padding(.horizontal, theme.spacing.lg)

                    problemCard(
                        title: "Longest Substring Without Repeating Characters",
                        difficulty: .medium,
                        isSolved: false
                    )
                    .padding(.horizontal, theme.spacing.lg)

                    problemCard(
                        title: "Median of Two Sorted Arrays",
                        difficulty: .hard,
                        isSolved: false
                    )
                    .padding(.horizontal, theme.spacing.lg)
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
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

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0x9CA3AF))

            if searchText.isEmpty {
                Text("Search problems...")
                    .font(theme.typography.body)
                    .foregroundColor(Color(hex: 0x9CA3AF))
            }

            TextField("", text: $searchText)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .frame(height: 44)
        .background(Color(hex: 0xF3F4F6))
        .cornerRadius(theme.radii.md)
    }

    // MARK: - Problem Card

    private func problemCard(
        title: String,
        difficulty: TaskDifficulty,
        isSolved: Bool
    ) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.colors.textPrimary)

                Text(difficulty.rawValue)
                    .font(theme.typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(difficulty.textColor)
                    .padding(.horizontal, theme.spacing.sm)
                    .padding(.vertical, theme.spacing.xs)
                    .background(difficulty.bgColor)
                    .cornerRadius(theme.radii.sm)
            }

            Spacer()

            // Completion indicator
            if isSolved {
                ZStack {
                    Circle()
                        .fill(theme.colors.success)
                        .frame(width: 24, height: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Circle()
                    .stroke(Color(hex: 0xD1D5DB), lineWidth: 1.5)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(theme.spacing.lg)
        .background(theme.colors.surface)
        .cornerRadius(theme.radii.md)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.md)
                .stroke(theme.colors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    iPhoneCodingListView()
}
