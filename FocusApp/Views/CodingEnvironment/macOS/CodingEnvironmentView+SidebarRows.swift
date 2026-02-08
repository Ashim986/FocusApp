#if os(macOS)
import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    func sectionView(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: DSLayout.spacing(8)) {
            HStack {
                Text(section.isToday
                     ? L10n.Coding.sectionToday(section.dayId)
                     : L10n.Coding.sectionBacklog(section.dayId))
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: DSLayout.spacing(6)) {
                ForEach(section.problems) { item in
                    sidebarRow(item)
                }
            }
        }
    }

    func sidebarRow(_ item: CodingProblemItem) -> some View {
        let isSelected = presenter.selectedProblem?.id == item.problem.id

        return DSActionButton(action: {
            presenter.selectProblem(item)
        }, label: {
            HStack(spacing: DSLayout.spacing(10)) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(theme.colors.success)
                    } else {
                        Text("\(item.index + 1)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: DSLayout.spacing(2)) {
                    Text(item.problem.displayName)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                        .lineLimit(1)

                    Text(item.problem.difficulty.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(item.problem.difficulty == .easy ? theme.colors.success : theme.colors.warning)
                }

                Spacer()
            }
            .padding(.horizontal, DSLayout.spacing(10))
            .padding(.vertical, DSLayout.spacing(8))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? theme.colors.primary.opacity(0.2) : Color.clear)
            )
        })
    }
}

#endif
