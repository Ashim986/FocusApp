import SwiftUI

extension CodingEnvironmentView {
    var problemSelector: some View {
        Button(action: {
            showProblemPicker.toggle()
        }, label: {
            HStack(spacing: 8) {
                if let problem = presenter.selectedProblem {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(problem.name)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(problem.difficulty.rawValue)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(problem.difficulty == .easy ? Color.appGreen : Color.appAmber)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    (problem.difficulty == .easy ? Color.appGreen : Color.appAmber).opacity(0.15)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }

                        Text(
                            L10n.Coding.problemPickerDayTopic(
                                selectedDayLabel,
                                presenter.selectedDayTopic
                            )
                        )
                            .font(.system(size: 10))
                            .foregroundColor(Color.appGray500)
                    }
                } else {
                    Text(L10n.Coding.problemPickerSelect)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.appGray400)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray500)

                if presenter.isLoadingProblem {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray800)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appGray700, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
        .popover(isPresented: $showProblemPicker, arrowEdge: .bottom) {
            problemPickerPopover
        }
    }

    var selectedDayLabel: Int {
        presenter.selectedProblemDay == 0 ? presenter.currentDayNumber : presenter.selectedProblemDay
    }

    var problemPickerPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(L10n.Coding.problemPickerTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(L10n.Coding.problemPickerPendingLeft( pendingProblemCount))
                    .font(.system(size: 10))
                    .foregroundColor(Color.appGray500)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.appGray800)

            Divider()
                .background(Color.appGray700)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(presenter.problemSections) { section in
                        problemSection(section)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 320)
        .background(Color.appGray900)
    }

    var pendingProblemCount: Int {
        presenter.problemSections
            .flatMap { $0.problems }
            .filter { !$0.isCompleted }
            .count
    }

    func problemSection(_ section: CodingProblemSection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(section.isToday
                     ? L10n.Coding.sectionToday( section.dayId)
                     : L10n.Coding.sectionBacklog( section.dayId))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray400)

                Spacer()

                Text("\(section.completedCount)/\(section.totalCount)")
                    .font(.system(size: 9))
                    .foregroundColor(Color.appGray500)
            }

            VStack(spacing: 2) {
                ForEach(section.problems) { item in
                    problemRow(item: item)
                }
            }
        }
    }

    func problemRow(item: CodingProblemItem) -> some View {
        let isSelected = presenter.selectedProblem?.id == item.problem.id

        return Button(action: {
            presenter.selectProblem(item)
            showProblemPicker = false
        }, label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color.appGreen : Color.appGray600, lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color.appGreen)
                    } else {
                        Text("\(item.index + 1)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color.appGray500)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.problem.name)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : Color.appGray300)
                        .lineLimit(1)

                    Text(item.problem.difficulty.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(item.problem.difficulty == .easy ? Color.appGreen : Color.appAmber)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.appPurple)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.appPurple.opacity(0.15) : Color.clear)
            )
        })
        .buttonStyle(.plain)
    }
}
