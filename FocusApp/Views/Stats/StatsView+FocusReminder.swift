import SwiftUI

extension StatsView {
    var blockedSitesReminder: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.appRed)

                Text(L10n.Stats.focusReminderTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()
            }

            Text(L10n.Stats.focusReminderBody)
                .font(.system(size: 13))
                .foregroundColor(Color.appGray600)

            FlowLayout(spacing: 6) {
                ForEach(blockedSites, id: \.self) { site in
                    Text(site)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appRedLight)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
