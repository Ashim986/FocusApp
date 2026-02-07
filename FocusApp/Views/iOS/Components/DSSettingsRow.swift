// DSSettingsRow.swift
// FocusApp — Settings row (56px height)
// Spec: FIGMA_SETUP_GUIDE.md §3.23

import SwiftUI

struct DSSettingsRow: View {
    var iconName: String
    var title: String
    var subtitle: String?
    var statusText: String?

    var body: some View {
        HStack(spacing: DSSpacing.space12) {
            // Icon in circle
            ZStack {
                Circle()
                    .fill(DSColor.gray100)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(DSColor.gray600)
            }

            // Content
            VStack(alignment: .leading, spacing: DSSpacing.space2) {
                Text(title)
                    .font(DSTypography.bodyStrong)
                    .foregroundColor(DSColor.gray900)

                if let subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.gray500)
                }
            }

            Spacer()

            if let statusText {
                Text(statusText)
                    .font(DSTypography.subbody)
                    .foregroundColor(DSColor.gray500)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(DSColor.gray400)
        }
        .padding(.horizontal, DSSpacing.space16)
        .frame(height: 56)
    }
}

#Preview {
    VStack(spacing: 0) {
        DSSettingsRow(iconName: "person", title: "Profile", subtitle: "John Doe")
        Divider().padding(.leading, 64)
        DSSettingsRow(iconName: "shield", title: "Security", subtitle: "Password, 2FA")
    }
}
