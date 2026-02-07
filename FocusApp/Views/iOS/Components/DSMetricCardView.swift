// DSMetricCardView.swift
// FocusApp — Metric card (label + large value)
// Spec: FIGMA_SETUP_GUIDE.md §3.11

import SwiftUI

struct DSMetricCardView: View {
    var label: String
    var value: String

    var body: some View {
        DSSurfaceCard {
            VStack(spacing: DSSpacing.space4) {
                Text(label)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColor.gray500)

                Text(value)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColor.gray900)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HStack(spacing: DSSpacing.space8) {
        DSMetricCardView(label: "Total Focus", value: "34h 12m")
        DSMetricCardView(label: "Current Streak", value: "12 Days")
    }
    .padding()
}
