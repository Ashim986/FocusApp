import SwiftUI

extension CodingEnvironmentView {
    var headerBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack, label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.appGray400)
                        .frame(width: 28, height: 28)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                })
                .buttonStyle(.plain)
                .help(L10n.Coding.exitHelp)

                Button(action: {
                    showProblemSidebar.toggle()
                }, label: {
                    Image(systemName: "sidebar.leading")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.appGray400)
                        .frame(width: 28, height: 28)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                })
                .buttonStyle(.plain)
                .help(showProblemSidebar
                      ? L10n.Coding.hideProblems
                      : L10n.Coding.showProblems)

                problemSelector
            }
            .padding(.leading, 12)

            Spacer()

            focusTimerIndicator

            Spacer()

            HStack(spacing: 10) {
                if let problem = presenter.selectedProblem, let url = URL(string: problem.url) {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                            Text(L10n.Coding.leetcodeLink)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(Color.appGray400)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }

                if presenter.isRunning {
                    Button(action: presenter.stopExecution, label: {
                        HStack(spacing: 5) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 9))
                            Text(L10n.Coding.stop)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appRed)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    })
                    .buttonStyle(.plain)
                    .keyboardShortcut(".", modifiers: .command)
                } else {
                    Button(action: presenter.runCode, label: {
                        HStack(spacing: 5) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            Text(L10n.Coding.run)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appGray700)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    })
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)

                    Button(action: presenter.runTests, label: {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text(L10n.Coding.submit)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    })
                    .buttonStyle(.plain)
                    .disabled(presenter.testCases.isEmpty)
                    .opacity(presenter.testCases.isEmpty ? 0.5 : 1)
                    .keyboardShortcut(KeyEquivalent.return, modifiers: [.command, .shift])

                    Button(action: { isShowingDebugLogs = true }, label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.appGray300)
                            .frame(width: 32, height: 32)
                            .background(Color.appGray800)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    })
                    .buttonStyle(.plain)
                    .help(L10n.Debug.logsTitle)
                }
            }
            .padding(.trailing, 12)
        }
        .frame(height: 52)
        .background(Color.appGray900)
        .overlay(
            Rectangle()
                .fill(Color.appGray700)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var focusTimerIndicator: some View {
        let remaining = max(focusPresenter.timeRemaining, 0)
        let minutes = remaining / 60
        let seconds = remaining % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        let progress = focusPresenter.progress
        let ringColor = focusPresenter.isCompleted ? Color.appGreen : Color.appPurple
        let labelText = focusPresenter.isCompleted
            ? L10n.Coding.timerDone
            : timeString
        let labelColor = focusPresenter.isCompleted ? Color.appGreen : Color.white

        return HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.appGray700, lineWidth: 2)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 16, height: 16)

            Text(labelText)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(labelColor)

            Button(action: {
                focusPresenter.duration = 30
                focusPresenter.startTimer()
            }, label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color.appGray400)
            })
            .buttonStyle(.plain)
            .help(L10n.Coding.timerRestartHelp)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.appGray800)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.appGray700, lineWidth: 1)
        )
    }
}
