// DSSignOutButton.swift
// FocusApp — Sign out button (361x48)
// Spec: FIGMA_SETUP_GUIDE.md §3.25

import SwiftUI

struct DSSignOutButton: View {
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: DSSpacing.space8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("Sign Out")
                    .font(DSTypography.bodyStrong)
            }
            .foregroundColor(DSColor.red)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(DSColor.redLight)
            .cornerRadius(DSRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DSSignOutButton()
        .padding()
}
