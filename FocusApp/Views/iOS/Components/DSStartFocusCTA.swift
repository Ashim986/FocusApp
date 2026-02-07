// DSStartFocusCTA.swift
// FocusApp — Start Focus CTA card (361x88)
// Spec: FIGMA_SETUP_GUIDE.md §3.7

import SwiftUI

struct DSStartFocusCTA: View {
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: DSSpacing.space8) {
                ZStack {
                    Circle()
                        .fill(DSColor.purple.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DSColor.purple)
                }

                Text("Start Focus Session")
                    .font(DSTypography.bodyStrong)
                    .foregroundColor(DSColor.gray900)

                Text("Ready to get in the zone?")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColor.gray500)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(DSColor.surface)
            .cornerRadius(DSRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.medium)
                    .strokeBorder(
                        DSColor.divider,
                        style: StrokeStyle(lineWidth: 1, dash: [4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DSStartFocusCTA()
        .padding()
}
