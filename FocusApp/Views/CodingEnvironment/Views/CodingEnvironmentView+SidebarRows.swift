import FocusDesignSystem
import SwiftUI

extension CodingEnvironmentView {
    func sectionView(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DSText(section.isToday
                     ? L10n.Coding.sectionToday(section.dayId)
                     : L10n.Coding.sectionBacklog(section.dayId))
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)

                Spacer()

                DSText("\(section.completedCount)/\(section.totalCount)")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            VStack(spacing: 6) {
                ForEach(section.problems) { item in
                    sidebarRow(item)
                }
            }
        }
    }

    func sidebarRow(_ item: CodingProblemItem) -> some View {
        let isSelected = presenter.selectedProblem?.id == item.problem.id

        return DSButton(action: {
            presenter.selectProblem(item)
        }, label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? theme.colors.success : theme.colors.border, lineWidth: 1.5)
                        .frame(width: 18, height: 18)

                    if item.isCompleted {
                        DSImage(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(theme.colors.success)
                    } else {
                        DSText("\(item.index + 1)")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    DSText(item.problem.displayName)
                        .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                        .lineLimit(1)

                    DSText(item.problem.difficulty.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(item.problem.difficulty == .easy ? theme.colors.success : theme.colors.warning)
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? theme.colors.primary.opacity(0.2) : Color.clear)
            )
        })
        .buttonStyle(.plain)
    }
}
