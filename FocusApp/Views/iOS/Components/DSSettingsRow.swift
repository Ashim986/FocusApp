// LegacyDSSettingsRow.swift
// FocusApp — Settings row (56px height)
// Spec: FIGMA_SETUP_GUIDE.md §3.23

import SwiftUI

struct LegacyDSSettingsRow: View {
    var iconName: String
    var title: String
    var subtitle: String?
    var statusText: String?

    var body: some View {
        HStack(spacing: DSLayout.spacing(.space12)) {
            // Icon in circle
            ZStack {
                Circle()
                    .fill(LegacyDSColor.gray100)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(LegacyDSColor.gray600)
            }

            // Content
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space2)) {
                Text(title)
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(LegacyDSColor.gray900)

                if let subtitle {
                    Text(subtitle)
                        .font(LegacyDSTypography.caption)
                        .foregroundColor(LegacyDSColor.gray500)
                }
            }

            Spacer()

            if let statusText {
                Text(statusText)
                    .font(LegacyDSTypography.subbody)
                    .foregroundColor(LegacyDSColor.gray500)
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(LegacyDSColor.gray400)
        }
        .padding(.horizontal, DSLayout.spacing(.space16))
        .frame(height: 56)
    }
}

#Preview {
    VStack(spacing: 0) {
        LegacyDSSettingsRow(iconName: "person", title: "Profile", subtitle: "John Doe")
        Divider().padding(.leading, DSLayout.spacing(64))
        LegacyDSSettingsRow(iconName: "shield", title: "Security", subtitle: "Password, 2FA")
    }
}
