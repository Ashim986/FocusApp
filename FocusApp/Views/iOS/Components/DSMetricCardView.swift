// LegacyDSMetricCardView.swift
// FocusApp — Metric card (label + large value)
// Spec: FIGMA_SETUP_GUIDE.md §3.11

import SwiftUI

struct LegacyDSMetricCardView: View {
    var label: String
    var value: String

    var body: some View {
        LegacyDSSurfaceCard {
            VStack(spacing: DSLayout.spacing(.space4)) {
                Text(label)
                    .font(LegacyDSTypography.caption)
                    .foregroundColor(LegacyDSColor.gray500)

                Text(value)
                    .font(LegacyDSTypography.headline)
                    .foregroundColor(LegacyDSColor.gray900)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HStack(spacing: DSLayout.spacing(.space8)) {
        LegacyDSMetricCardView(label: "Total Focus", value: "34h 12m")
        LegacyDSMetricCardView(label: "Current Streak", value: "12 Days")
    }
    .padding()
}
