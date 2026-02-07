import FocusDesignSystem
import SwiftUI

extension ToolbarWidgetView {
    var tomorrowSection: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showTomorrow.toggle()
                }
            }, label: {
                HStack {
                    Image(systemName: showTomorrow ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9))
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(width: 12)

                    Text(L10n.Widget.tomorrowTitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(theme.colors.textPrimary.opacity(0.75))

                    if !presenter.carryoverProblems.isEmpty {
                        Text(L10n.Widget.tomorrowCarryoverCount(presenter.carryoverProblems.count))
                            .font(.system(size: 9))
                            .foregroundColor(theme.colors.warning.opacity(0.85))
                    }

                    Spacer()

                    if presenter.hasTomorrow {
                        Text(L10n.Widget.tomorrowDayFormat(presenter.tomorrowDayNumber))
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
            })
            .buttonStyle(.plain)
            .padding(.vertical, 4)

            if showTomorrow {
                VStack(spacing: 0) {
                    if !presenter.carryoverProblems.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "arrow.uturn.forward")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.colors.warning)
                                Text(L10n.Widget.tomorrowCarryoverTitle)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(theme.colors.warning)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)

                            ForEach(presenter.carryoverProblems, id: \.problem.id) { item in
                                CarryoverProblemRow(problem: item.problem) {
                                    presenter.toggleProblem(day: presenter.currentDayNumber, problemIndex: item.index)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                        .padding(.bottom, 8)
                    }

                    if presenter.hasTomorrow {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.colors.primary)
                                Text(presenter.tomorrowsTopic)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(theme.colors.primary)
                                Spacer()
                                Text(L10n.Widget.tomorrowProblemCount(presenter.tomorrowsProblems.count))
                                    .font(.system(size: 9))
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)

                            ScrollView {
                                VStack(spacing: 2) {
                                    ForEach(presenter.tomorrowsProblems) { problem in
                                        TomorrowProblemRow(problem: problem)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .frame(maxHeight: 120)
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
}
