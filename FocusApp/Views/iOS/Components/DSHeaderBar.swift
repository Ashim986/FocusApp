// LegacyDSHeaderBar.swift
// FocusApp — iPhone header bar (393x44)
// Spec: FIGMA_SETUP_GUIDE.md §3.3

import SwiftUI

struct LegacyDSHeaderBar: View {
    var title: String = "FocusApp"
    var showSettings: Bool = true
    var onSettingsTap: (() -> Void)?

    var body: some View {
        HStack {
            Spacer()

            Text(title)
                .font(LegacyDSTypography.bodyStrong)
                .foregroundColor(LegacyDSColor.textPrimary)

            Spacer()
        }
        .overlay(alignment: .trailing) {
            if showSettings {
                Button {
                    onSettingsTap?()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(LegacyDSColor.gray600)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .padding(.trailing, DSLayout.spacing(.space16))
            }
        }
        .frame(height: 44)
        .padding(.horizontal, DSLayout.spacing(.space16))
        .background(LegacyDSColor.background)
    }
}

#Preview {
    LegacyDSHeaderBar()
}
