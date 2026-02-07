// LegacyDSStartFocusCTA.swift
// FocusApp — Start Focus CTA card (361x88)
// Spec: FIGMA_SETUP_GUIDE.md §3.7

import SwiftUI

struct LegacyDSStartFocusCTA: View {
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: DSLayout.spacing(.space8)) {
                ZStack {
                    Circle()
                        .fill(LegacyDSColor.purple.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(LegacyDSColor.purple)
                }

                Text("Start Focus Session")
                    .font(LegacyDSTypography.bodyStrong)
                    .foregroundColor(LegacyDSColor.gray900)

                Text("Ready to get in the zone?")
                    .font(LegacyDSTypography.caption)
                    .foregroundColor(LegacyDSColor.gray500)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(LegacyDSColor.surface)
            .cornerRadius(LegacyDSRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: LegacyDSRadius.medium)
                    .strokeBorder(
                        LegacyDSColor.divider,
                        style: StrokeStyle(lineWidth: 1, dash: [4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LegacyDSStartFocusCTA()
        .padding()
}
