#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension TodayView {
    var codingCTACard: some View {
        VStack(spacing: DSLayout.spacing(16)) {
            HStack(spacing: DSLayout.spacing(12)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(4)) {
                    Text(L10n.Today.ctaTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(L10n.Today.ctaSubtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                DSButton(
                    L10n.Today.ctaButton,
                    config: .init(
                        style: .secondary,
                        size: .small,
                        icon: Image(systemName: "chevron.left.slash.chevron.right")
                    )
                ) {
                    onOpenCodingEnvironment?()
                }
            }

            Text(L10n.Today.ctaFooter)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(DSLayout.spacing(20))
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [theme.colors.primary, theme.colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#endif
