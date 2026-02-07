// LegacyDSSearchBar.swift
// FocusApp — Search bar (361x44)
// Spec: FIGMA_SETUP_GUIDE.md §3.24

import SwiftUI

struct LegacyDSSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search problems..."

    var body: some View {
        HStack(spacing: DSLayout.spacing(.space8)) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(LegacyDSColor.gray400)

            if text.isEmpty {
                Text(placeholder)
                    .font(LegacyDSTypography.body)
                    .foregroundColor(LegacyDSColor.gray400)
            }

            TextField("", text: $text)
                .font(LegacyDSTypography.body)
                .foregroundColor(LegacyDSColor.textPrimary)

            Spacer()
        }
        .padding(.horizontal, DSLayout.spacing(.space12))
        .frame(height: 44)
        .background(LegacyDSColor.gray100)
        .cornerRadius(LegacyDSRadius.medium)
    }
}

#Preview {
    LegacyDSSearchBar(text: .constant(""))
        .padding()
}
