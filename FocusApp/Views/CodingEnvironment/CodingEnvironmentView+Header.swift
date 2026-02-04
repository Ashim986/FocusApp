import SwiftUI

extension CodingEnvironmentView {
    var headerBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.appGray400)
                        .frame(width: 28, height: 28)
                        .background(Color.appGray800)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help("Exit coding mode")

                problemSelector
            }
            .padding(.leading, 12)

            Spacer()

            languageToggle
                .padding(.horizontal, 16)

            Spacer()

            HStack(spacing: 8) {
                if let problem = presenter.selectedProblem {
                    Link(destination: URL(string: problem.url)!) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10))
                            Text("LeetCode")
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
                    Button(action: presenter.stopExecution) {
                        HStack(spacing: 5) {
                            Image(systemName: "stop.fill")
                                .font(.system(size: 9))
                            Text("Stop")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appRed)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(".", modifiers: .command)
                } else {
                    Button(action: presenter.runCode) {
                        HStack(spacing: 5) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 9))
                            Text("Run")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appGray700)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("r", modifiers: .command)

                    Button(action: presenter.runTests) {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("Submit")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.appGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .disabled(presenter.testCases.isEmpty)
                    .opacity(presenter.testCases.isEmpty ? 0.5 : 1)
                    .keyboardShortcut(KeyEquivalent.return, modifiers: [.command, .shift])
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

    var languageToggle: some View {
        HStack(spacing: 0) {
            ForEach(ProgrammingLanguage.allCases, id: \.rawValue) { lang in
                Button(action: { presenter.changeLanguage(lang) }) {
                    Text(lang.rawValue)
                        .font(.system(size: 11, weight: presenter.language == lang ? .semibold : .regular))
                        .foregroundColor(presenter.language == lang ? .white : Color.appGray500)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            presenter.language == lang ?
                            Color.appPurple : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color.appGray800)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
