import SwiftUI

struct TodayView: View {
    @ObservedObject var presenter: TodayPresenter
    @Binding var showFocusMode: Bool
    @Binding var showCodeEnvironment: Bool

    let blockedSites = [
        "YouTube", "Twitter/X", "Reddit", "Instagram",
        "TikTok", "Facebook", "Netflix", "Twitch"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                focusCTACard

                habitsCard

                ForEach(presenter.visibleDays) { day in
                    dayCard(day: day)
                }
            }
            .padding(20)
        }
        .background(Color.appGray50)
    }
}
