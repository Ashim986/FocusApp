#if os(macOS)
import FocusDesignSystem
import SwiftUI

struct StatsView: View {
    @ObservedObject var presenter: StatsPresenter
    @Environment(\.dsTheme) var theme

    let blockedSites = [
        "YouTube", "Twitter/X", "Reddit", "Instagram",
        "TikTok", "Facebook", "Netflix", "Twitch"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DSLayout.spacing(20)) {
                statCardsGrid
                preCompletedSection
                topicBreakdownSection
                blockedSitesReminder
            }
            .padding(DSLayout.spacing(20))
        }
        .background(theme.colors.background)
    }
}

#endif
