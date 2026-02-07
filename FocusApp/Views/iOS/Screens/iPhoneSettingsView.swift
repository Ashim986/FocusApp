// iPhoneSettingsView.swift
// FocusApp — iPhone Settings screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.12

import SwiftUI
import FocusDesignSystem

struct iPhoneSettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space16)) {
                    // Title
                    Text("Settings")
                        .font(DSMobileTypography.headline)
                        .foregroundColor(DSMobileColor.textPrimary)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    // ACCOUNT section
                    Text("ACCOUNT")
                        .font(DSMobileTypography.captionStrong)
                        .foregroundColor(DSMobileColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    DSSurfaceCard(padding: 0) {
                        VStack(spacing: 0) {
                            DSSettingsRow(
                                iconName: "person",
                                title: "Profile",
                                subtitle: "John Doe"
                            )

                            Divider()
                                .padding(.leading, DSLayout.spacing(64))

                            DSSettingsRow(
                                iconName: "shield",
                                title: "Security",
                                subtitle: "Password, 2FA"
                            )
                        }
                    }
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    // PREFERENCES section
                    Text("PREFERENCES")
                        .font(DSMobileTypography.captionStrong)
                        .foregroundColor(DSMobileColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSLayout.spacing(.space16))

                    DSSurfaceCard(padding: 0) {
                        VStack(spacing: 0) {
                            DSSettingsRow(
                                iconName: "bell",
                                title: "Notifications",
                                statusText: "On"
                            )

                            Divider()
                                .padding(.leading, DSLayout.spacing(64))

                            DSSettingsRow(
                                iconName: "moon",
                                title: "Appearance",
                                statusText: "Light"
                            )
                        }
                    }
                    .padding(.horizontal, DSLayout.spacing(.space16))

                    // Sign Out
                    DSSignOutButton()
                        .padding(.horizontal, DSLayout.spacing(.space16))
                        .padding(.top, DSLayout.spacing(.space8))
                }
                .padding(.top, DSLayout.spacing(.space8))
                .padding(.bottom, DSLayout.spacing(.space32))
            }
        }
        .background(DSMobileColor.background)
    }
}

#Preview {
    iPhoneSettingsView()
}
