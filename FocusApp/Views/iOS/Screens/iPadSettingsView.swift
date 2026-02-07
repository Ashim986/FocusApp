// iPadSettingsView.swift
// FocusApp — iPad Settings screen
// Spec: FIGMA_SETUP_GUIDE.md §5.6

import SwiftUI
import FocusDesignSystem

struct iPadSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                // Title
                Text("Settings")
                    .font(DSMobileTypography.headline)
                    .foregroundColor(DSMobileColor.textPrimary)
                    .padding(.top, DSLayout.spacing(.space24))

                // ACCOUNT section
                Text("ACCOUNT")
                    .font(DSMobileTypography.captionStrong)
                    .foregroundColor(DSMobileColor.gray500)
                    .textCase(.uppercase)

                DSSurfaceCard(padding: 0) {
                    VStack(spacing: 0) {
                        DSSettingsRow(
                            iconName: "person",
                            title: "Profile",
                            subtitle: "John Doe"
                        )
                        Divider().padding(.leading, DSLayout.spacing(64))
                        DSSettingsRow(
                            iconName: "shield",
                            title: "Security",
                            subtitle: "Password, 2FA"
                        )
                    }
                }

                // PREFERENCES section
                Text("PREFERENCES")
                    .font(DSMobileTypography.captionStrong)
                    .foregroundColor(DSMobileColor.gray500)
                    .textCase(.uppercase)

                DSSurfaceCard(padding: 0) {
                    VStack(spacing: 0) {
                        DSSettingsRow(
                            iconName: "bell",
                            title: "Notifications",
                            statusText: "On"
                        )
                        Divider().padding(.leading, DSLayout.spacing(64))
                        DSSettingsRow(
                            iconName: "moon",
                            title: "Appearance",
                            statusText: "Light"
                        )
                    }
                }

                // Sign Out
                DSSignOutButton()
                    .padding(.top, DSLayout.spacing(.space8))
            }
            .frame(maxWidth: 500)
            .padding(.horizontal, DSLayout.spacing(.space24))
            .frame(maxWidth: .infinity)
            .padding(.bottom, DSLayout.spacing(.space48))
        }
    }
}

#Preview {
    iPadSettingsView()
        .frame(width: 574, height: 1194)
}
