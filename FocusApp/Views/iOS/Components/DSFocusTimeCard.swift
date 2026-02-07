// LegacyDSFocusTimeCard.swift
// FocusApp — Focus time display card (361x100)
// Spec: FIGMA_SETUP_GUIDE.md §3.6

import SwiftUI

struct LegacyDSFocusTimeCard: View {
    var focusTime: String = "2h 15m"
    var remainingText: String = "35m remaining today"

    var body: some View {
        LegacyDSSurfaceCard {
            HStack(spacing: DSLayout.spacing(.space12)) {
                // Pulse icon in circle
                ZStack {
                    Circle()
                        .fill(LegacyDSColor.greenLight)
                        .frame(width: 40, height: 40)
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18))
                        .foregroundColor(LegacyDSColor.green)
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text("Focus Time")
                        .font(LegacyDSTypography.subbodyStrong)
                        .foregroundColor(LegacyDSColor.gray500)

                    Text(focusTime)
                        .font(LegacyDSTypography.headline)
                        .foregroundColor(LegacyDSColor.gray900)

                    Text(remainingText)
                        .font(LegacyDSTypography.caption)
                        .foregroundColor(LegacyDSColor.gray500)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    LegacyDSFocusTimeCard()
        .padding()
}
