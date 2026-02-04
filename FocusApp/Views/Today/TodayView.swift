import SwiftUI

struct TodayView: View {
    @ObservedObject var presenter: TodayPresenter
    @Binding var showCodeEnvironment: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                codingCTACard
                syncCard

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
