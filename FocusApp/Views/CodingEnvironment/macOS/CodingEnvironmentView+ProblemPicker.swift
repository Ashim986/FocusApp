#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    var problemSelector: some View {
        DSActionButton(action: {
            codingCoordinator.isProblemPickerShown.toggle()
        }, label: {
            HStack(spacing: DSLayout.spacing(8)) {
                if let problem = presenter.selectedProblem {
                    VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                        HStack(spacing: DSLayout.spacing(6)) {
                            Text(problem.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.colors.textPrimary)
                                .lineLimit(1)

                            DSBadge(
                                problem.difficulty.rawValue.uppercased(),
                                config: .init(style: problem.difficulty == .easy ? .success : .warning)
                            )
                        }

                        Text(
                            L10n.Coding.problemPickerDayTopic(
                                selectedDayLabel,
                                presenter.selectedDayTopic
                            )
                        )
                            .font(.system(size: 10))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                } else {
                    Text(L10n.Coding.problemPickerSelect)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(theme.colors.textSecondary)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                if presenter.isLoadingProblem {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, DSLayout.spacing(12))
            .padding(.vertical, DSLayout.spacing(8))
            .background(theme.colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.colors.border, lineWidth: 1)
            )
        })
        .popover(isPresented: $codingCoordinator.isProblemPickerShown, arrowEdge: .bottom) {
            problemPickerPopover
        }
    }

    var selectedDayLabel: Int {
        presenter.selectedProblemDay == 0 ? presenter.currentDayNumber : presenter.selectedProblemDay
    }

    var problemPickerPopover: some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(0)) {
            HStack {
                Text(L10n.Coding.problemPickerTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.colors.textPrimary)
                Spacer()
                Text(L10n.Coding.problemPickerPendingLeft(pendingProblemCount))
                    .font(.system(size: 10))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .padding(.horizontal, DSLayout.spacing(12))
            .padding(.vertical, DSLayout.spacing(10))
            .background(theme.colors.surfaceElevated)

            Divider()
                .background(theme.colors.border)

            ScrollView {
                VStack(spacing: DSLayout.spacing(12)) {
                    ForEach(presenter.problemSections) { section in
                        problemSection(section)
                    }
                }
                .padding(DSLayout.spacing(8))
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 320)
        .background(theme.colors.surface)
    }

    var pendingProblemCount: Int {
        presenter.problemSections
            .flatMap { $0.problems }
            .filter { !$0.isCompleted }
            .count
    }

    func problemSection(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(6)) {
            HStack {
                Text(section.isToday
                     ? L10n.Coding.sectionToday( section.dayId)
                     : L10n.Coding.sectionBacklog( section.dayId))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 9))
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: DSLayout.spacing(2)) {
                ForEach(section.problems) { item in
                    problemRow(item: item)
                }
            }
        }
    }

    func problemRow(item: CodingProblemItem) -> some View {
        let isSelected = presenter.selectedProblem?.id == item.problem.id

        return DSActionButton(action: {
            presenter.selectProblem(item)
            codingCoordinator.isProblemPickerShown = false
        }, label: {
            HStack(spacing: DSLayout.spacing(10)) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(theme.colors.success)
                    } else {
                        Text("\(item.index + 1)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                    Text(item.problem.displayName)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                        .lineLimit(1)

                    Text(item.problem.difficulty.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(item.problem.difficulty == .easy ? theme.colors.success : theme.colors.warning)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.primary)
                }
            }
            .padding(.horizontal, DSLayout.spacing(10))
            .padding(.vertical, DSLayout.spacing(8))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? theme.colors.primary.opacity(0.15) : Color.clear)
            )
        })
    }
}

#endif
