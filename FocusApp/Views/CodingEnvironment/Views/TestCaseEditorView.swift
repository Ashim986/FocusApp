import SwiftUI

struct TestCaseEditorView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
            Text(L10n.Coding.TestEditor.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: presenter.addManualTestCase) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text(L10n.Coding.TestEditor.add)
                    }
                    .font(.system(size: 11))
                    .foregroundColor(Color.appPurple)
                }
                .buttonStyle(.plain)
            }

            if presenter.testCases.isEmpty {
            Text(L10n.Coding.TestEditor.empty)
                    .font(.system(size: 11))
                    .foregroundColor(Color.appGray500)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(presenter.testCases.enumerated()), id: \.element.id) { index, testCase in
                    testCaseEditRow(index: index, testCase: testCase)
                }
            }
        }
    }

    private func testCaseEditRow(index: Int, testCase: TestCase) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(L10n.Coding.TestEditor.testFormat(index + 1))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.appGray400)

                Spacer()

                Button(action: {
                    presenter.removeTestCase(at: index)
                }, label: {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(Color.appGray500)
                })
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.Coding.TestEditor.inputLabel)
                        .font(.system(size: 10))
                        .foregroundColor(Color.appGray500)

                    TextField("", text: Binding(
                        get: { testCase.input },
                        set: { presenter.updateTestCaseInput(at: index, input: $0) }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.appGray800)
                    .cornerRadius(4)
                }

                VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Coding.TestEditor.expectedLabel)
                        .font(.system(size: 10))
                        .foregroundColor(Color.appGray500)

                    TextField("", text: Binding(
                        get: { testCase.expectedOutput },
                        set: { presenter.updateTestCaseExpectedOutput(at: index, output: $0) }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.appGray800)
                    .cornerRadius(4)
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.appGray800.opacity(0.3))
        )
    }
}
