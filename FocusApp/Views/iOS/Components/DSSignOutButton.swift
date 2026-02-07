// LegacyDSSignOutButton.swift
// FocusApp — Sign out button (361x48)
// Spec: FIGMA_SETUP_GUIDE.md §3.25

import SwiftUI

struct LegacyDSSignOutButton: View {
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: DSLayout.spacing(.space8)) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16))
                Text("Sign Out")
                    .font(LegacyDSTypography.bodyStrong)
            }
            .foregroundColor(LegacyDSColor.red)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(LegacyDSColor.redLight)
            .cornerRadius(LegacyDSRadius.medium)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LegacyDSSignOutButton()
        .padding()
}
