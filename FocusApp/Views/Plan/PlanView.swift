import FocusDesignSystem
import SwiftData
import SwiftUI

struct PlanView: View {
    @ObservedObject var presenter: PlanPresenter
    let onSelectProblem: (_ problem: Problem, _ day: Int, _ index: Int) -> Void
    @Environment(\.dsTheme) var theme

    var body: some View {
        ScrollView {
            VStack(spacing: DSLayout.spacing(.space16)) {
                preCompletedBanner
                syncCard

                ForEach(presenter.days) { day in
                    DayCard(
                        viewModel: day,
                        onToggleProblem: { index in
                            presenter.toggleProblem(day: day.id, problemIndex: index)
                        },
                        onSelectProblem: { index in
                            guard let problem = day.problems.first(where: { $0.index == index })?.problem else {
                                return
                            }
                            onSelectProblem(problem, day.id, index)
                        }
                    )
                }

                bufferNote
            }
            .padding(DSLayout.spacing(20))
        }
        .background(theme.colors.background)
    }

    private var preCompletedBanner: some View {
        DSCard(config: .init(style: .elevated)) {
            VStack(alignment: .leading, spacing: DSLayout.spacing(.space12)) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.colors.success)

                    Text(L10n.Plan.precompletedTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Text(L10n.Plan.precompletedCountFormat( preCompletedTopics.count))
                        .font(.system(size: 13))
                        .foregroundColor(theme.colors.textSecondary)
                }

                FlowLayout(spacing: DSLayout.spacing(.space8)) {
                    ForEach(preCompletedTopics, id: \.self) { topic in
                        HStack(spacing: DSLayout.spacing(4)) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))

                            Text(topic)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(theme.colors.success)
                        .padding(.horizontal, DSLayout.spacing(10))
                        .padding(.vertical, DSLayout.spacing(6))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(theme.colors.success.opacity(0.15))
                        )
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.lg)
                .strokeBorder(theme.colors.success.opacity(0.3), lineWidth: 1)
        )
    }

    private var syncCard: some View {
        DSCard(config: .init(style: .elevated)) {
            HStack(spacing: DSLayout.spacing(.space16)) {
                VStack(alignment: .leading, spacing: DSLayout.spacing(.space4)) {
                    Text(L10n.Plan.syncTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary)

                    Text(presenter.lastSyncResult.isEmpty
                         ? L10n.Plan.syncDefaultStatus
                         : presenter.lastSyncResult)
                        .font(.system(size: 12))
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                if presenter.isSyncing {
                    ProgressView()
                        .scaleEffect(0.9)
                        .tint(theme.colors.primary)
                } else {
                    DSButton(
                        L10n.Plan.syncNow,
                        config: .init(style: .primary, size: .small, icon: Image(systemName: "arrow.triangle.2.circlepath"))
                    ) {
                        presenter.syncNow()
                    }
                }
            }
        }
    }

    private var bufferNote: some View {
        HStack(spacing: DSLayout.spacing(.space12)) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 20))
                .foregroundColor(theme.colors.primary)

            VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                Text(L10n.Plan.bufferTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textPrimary)

                Text(L10n.Plan.bufferBody)
                    .font(.system(size: 12))
                    .foregroundColor(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(DSLayout.spacing(.space16))
        .background(
            RoundedRectangle(cornerRadius: DSLayout.spacing(.space12))
                .fill(theme.colors.primary.opacity(0.12))
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
        Group {
            if let container = try? ModelContainer(for: AppDataRecord.self) {
                let appStore = AppStateStore(storage: SwiftDataAppStorage(container: container))
                let client = PreviewLeetCodeClient()
                let leetCodeSync = LeetCodeSyncInteractor(appStore: appStore, client: client)
                let presenter = PlanPresenter(
                    interactor: PlanInteractor(
                        appStore: appStore,
                        notificationManager: NotificationManager(
                            scheduler: SystemNotificationScheduler(),
                            store: UserDefaultsNotificationSettingsStore()
                        ),
                        leetCodeSync: leetCodeSync
                    )
                )
                PlanView(
                    presenter: presenter,
                    onSelectProblem: { _, _, _ in }
                )
                    .frame(width: 600, height: 800)
            } else {
                Text("Preview unavailable")
            }
        }
    }
}

private struct PreviewLeetCodeClient: LeetCodeClientProtocol {
    func validateUsername(_ username: String) async throws -> Bool { true }
    func fetchSolvedSlugs(username: String, limit: Int) async throws -> Set<String> { [] }
    func fetchProblemContent(slug: String) async throws -> QuestionContent? { nil }
}
#endif
