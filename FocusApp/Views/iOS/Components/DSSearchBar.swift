// DSSearchBar.swift
// FocusApp — Search bar (361x44)
// Spec: FIGMA_SETUP_GUIDE.md §3.24

import SwiftUI

struct DSSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search problems..."

    var body: some View {
        HStack(spacing: DSSpacing.space8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(DSColor.gray400)

            if text.isEmpty {
                Text(placeholder)
                    .font(DSTypography.body)
                    .foregroundColor(DSColor.gray400)
            }

            TextField("", text: $text)
                .font(DSTypography.body)
                .foregroundColor(DSColor.textPrimary)

            Spacer()
        }
        .padding(.horizontal, DSSpacing.space12)
        .frame(height: 44)
        .background(DSColor.gray100)
        .cornerRadius(DSRadius.medium)
    }
}

#Preview {
    DSSearchBar(text: .constant(""))
        .padding()
}
