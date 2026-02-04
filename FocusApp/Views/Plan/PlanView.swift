import SwiftUI

struct PlanView: View {
    @ObservedObject var presenter: PlanPresenter

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                preCompletedBanner

                ForEach(presenter.days) { day in
                    DayCard(
                        viewModel: day,
                        onToggleProblem: { index in
                            presenter.toggleProblem(day: day.id, problemIndex: index)
                        }
                    )
                }

                bufferNote
            }
            .padding(20)
        }
        .background(Color.appGray50)
    }

    private var preCompletedBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.appGreen)

                Text("Already Completed")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appGray800)

                Spacer()

                Text("\(preCompletedTopics.count) topics")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appGray500)
            }

            FlowLayout(spacing: 8) {
                ForEach(preCompletedTopics, id: \.self) { topic in
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))

                        Text(topic)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.appGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appGreenLight)
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.appGreen.opacity(0.3), lineWidth: 1)
        )
    }

    private var bufferNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20))
                .foregroundColor(Color.appPurple)

            VStack(alignment: .leading, spacing: 2) {
                Text("Buffer Days: Feb 16-17")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.appGray700)

                Text("Use these for catch-up or extra practice before your interview")
                    .font(.system(size: 12))
                    .foregroundColor(Color.appGray500)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appPurple.opacity(0.1))
        )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#if DEBUG
struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        let appStore = AppStateStore(storage: FileAppStorage())
        let presenter = PlanPresenter(
            interactor: PlanInteractor(
                appStore: appStore,
                notificationManager: NotificationManager(
                    scheduler: SystemNotificationScheduler(),
                    store: UserDefaultsNotificationSettingsStore()
                )
            )
        )
        return PlanView(presenter: presenter)
            .frame(width: 600, height: 800)
    }
}
#endif
