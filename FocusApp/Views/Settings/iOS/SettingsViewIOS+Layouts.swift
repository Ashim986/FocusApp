#if os(iOS)
// SettingsViewIOS+Layouts.swift
// FocusApp -- iOS layout variants for Settings.

import FocusDesignSystem
import SwiftUI

extension SettingsViewIOS {

    // MARK: - Regular Layout (iPad)

    var regularLayout: some View {
        NavigationView {
            ScrollView {
                settingsContent
                    .frame(maxWidth: 500)
                    .padding(.horizontal, theme.spacing.xl)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 48)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            presenter.onAppear()
        }
    }

    // MARK: - Compact Layout (iPhone)

    var compactLayout: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    Text("Settings")
                        .font(theme.typography.subtitle)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.horizontal, theme.spacing.lg)

                    settingsContent
                }
                .padding(.top, theme.spacing.sm)
                .padding(.bottom, 32)
            }
        }
        .background(theme.colors.background)
        .onAppear {
            presenter.onAppear()
        }
    }

    // MARK: - Header Bar (Compact only)

    private var headerBar: some View {
        HStack {
            Spacer()

            Text("FocusApp")
                .font(theme.typography.body)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.textPrimary)

            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, theme.spacing.lg)
        .background(theme.colors.background)
    }
}

#endif
