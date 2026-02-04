import SwiftUI

struct StatsView: View {
    @ObservedObject var presenter: StatsPresenter

    let blockedSites = [
        "YouTube", "Twitter/X", "Reddit", "Instagram",
        "TikTok", "Facebook", "Netflix", "Twitch"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statCardsGrid
                preCompletedSection
                topicBreakdownSection
                blockedSitesReminder
            }
            .padding(20)
        }
        .background(Color.appGray50)
    }
}
