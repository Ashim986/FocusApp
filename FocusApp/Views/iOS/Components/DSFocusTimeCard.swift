// DSFocusTimeCard.swift
// FocusApp — Focus time display card (361x100)
// Spec: FIGMA_SETUP_GUIDE.md §3.6

import SwiftUI

struct DSFocusTimeCard: View {
    var focusTime: String = "2h 15m"
    var remainingText: String = "35m remaining today"

    var body: some View {
        DSSurfaceCard {
            HStack(spacing: DSSpacing.space12) {
                // Pulse icon in circle
                ZStack {
                    Circle()
                        .fill(DSColor.greenLight)
                        .frame(width: 40, height: 40)
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18))
                        .foregroundColor(DSColor.green)
                }

                VStack(alignment: .leading, spacing: DSSpacing.space4) {
                    Text("Focus Time")
                        .font(DSTypography.subbodyStrong)
                        .foregroundColor(DSColor.gray500)

                    Text(focusTime)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColor.gray900)

                    Text(remainingText)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColor.gray500)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    DSFocusTimeCard()
        .padding()
}
