// iPadSettingsView.swift
// FocusApp — iPad Settings screen
// Spec: FIGMA_SETUP_GUIDE.md §5.6

import SwiftUI

struct iPadSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.space16) {
                // Title
                Text("Settings")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColor.textPrimary)
                    .padding(.top, DSSpacing.space24)

                // ACCOUNT section
                Text("ACCOUNT")
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray500)
                    .textCase(.uppercase)

                DSSurfaceCard(padding: 0) {
                    VStack(spacing: 0) {
                        DSSettingsRow(
                            iconName: "person",
                            title: "Profile",
                            subtitle: "John Doe"
                        )
                        Divider().padding(.leading, 64)
                        DSSettingsRow(
                            iconName: "shield",
                            title: "Security",
                            subtitle: "Password, 2FA"
                        )
                    }
                }

                // PREFERENCES section
                Text("PREFERENCES")
                    .font(DSTypography.captionStrong)
                    .foregroundColor(DSColor.gray500)
                    .textCase(.uppercase)

                DSSurfaceCard(padding: 0) {
                    VStack(spacing: 0) {
                        DSSettingsRow(
                            iconName: "bell",
                            title: "Notifications",
                            statusText: "On"
                        )
                        Divider().padding(.leading, 64)
                        DSSettingsRow(
                            iconName: "moon",
                            title: "Appearance",
                            statusText: "Light"
                        )
                    }
                }

                // Sign Out
                DSSignOutButton()
                    .padding(.top, DSSpacing.space8)
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, DSSpacing.space24)
            .frame(maxWidth: .infinity)
            .padding(.bottom, DSSpacing.space48)
        }
    }
}

#Preview {
    iPadSettingsView()
        .frame(width: 574, height: 1194)
}
