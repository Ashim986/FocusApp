// iPhoneSettingsView.swift
// FocusApp — iPhone Settings screen (393x852)
// Spec: FIGMA_SETUP_GUIDE.md §4.12

import SwiftUI

struct iPhoneSettingsView: View {
    var body: some View {
        VStack(spacing: 0) {
            DSHeaderBar()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.space16) {
                    // Title
                    Text("Settings")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.space16)

                    // ACCOUNT section
                    Text("ACCOUNT")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSSpacing.space16)

                    DSSurfaceCard(padding: 0) {
                        VStack(spacing: 0) {
                            DSSettingsRow(
                                iconName: "person",
                                title: "Profile",
                                subtitle: "John Doe"
                            )

                            Divider()
                                .padding(.leading, 64)

                            DSSettingsRow(
                                iconName: "shield",
                                title: "Security",
                                subtitle: "Password, 2FA"
                            )
                        }
                    }
                    .padding(.horizontal, DSSpacing.space16)

                    // PREFERENCES section
                    Text("PREFERENCES")
                        .font(DSTypography.captionStrong)
                        .foregroundColor(DSColor.gray500)
                        .textCase(.uppercase)
                        .padding(.horizontal, DSSpacing.space16)

                    DSSurfaceCard(padding: 0) {
                        VStack(spacing: 0) {
                            DSSettingsRow(
                                iconName: "bell",
                                title: "Notifications",
                                statusText: "On"
                            )

                            Divider()
                                .padding(.leading, 64)

                            DSSettingsRow(
                                iconName: "moon",
                                title: "Appearance",
                                statusText: "Light"
                            )
                        }
                    }
                    .padding(.horizontal, DSSpacing.space16)

                    // Sign Out
                    DSSignOutButton()
                        .padding(.horizontal, DSSpacing.space16)
                        .padding(.top, DSSpacing.space8)
                }
                .padding(.top, DSSpacing.space8)
                .padding(.bottom, DSSpacing.space32)
            }
        }
        .background(DSColor.background)
    }
}

#Preview {
    iPhoneSettingsView()
}
