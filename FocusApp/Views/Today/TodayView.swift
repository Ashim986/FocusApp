import SwiftUI

struct TodayView: View {
    @ObservedObject var presenter: TodayPresenter
    var onOpenCodingEnvironment: (() -> Void)?
    let onSelectProblem: (_ problem: Problem, _ day: Int, _ index: Int) -> Void

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
