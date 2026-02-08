#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension StatsView {
    var blockedSitesReminder: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(12)) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 16))
                        .foregroundColor(theme.colors.danger)

                    Text(L10n.Stats.focusReminderTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()
                }

                Text(L10n.Stats.focusReminderBody)
                    .font(.system(size: 13))
                    .foregroundColor(theme.colors.textSecondary)

                FlowLayout(spacing: DSLayout.spacing(6)) {
                    ForEach(blockedSites, id: \.self) { site in
                        DSBadge(site, config: .init(style: .danger))
                    }
                }
            }
        }
    }
}

#endif
