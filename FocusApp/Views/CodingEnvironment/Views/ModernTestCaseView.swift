import SwiftUI

struct ModernTestCaseView: View {
    @ObservedObject var presenter: CodingEnvironmentPresenter
    @State private var selectedTestIndex: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
            Text(L10n.Coding.Testcase.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                Spacer()

                Button(action: presenter.addManualTestCase) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.appGray400)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 12)
            }
            .background(Color.appGray800)
            .overlay(
                Rectangle()
                    .fill(Color.appGray700)
                    .frame(height: 1),
                alignment: .bottom
            )

            if presenter.testCases.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 20))
                        .foregroundColor(Color.appGray600)
                Text(L10n.Coding.Testcase.empty)
                        .font(.system(size: 11))
                        .foregroundColor(Color.appGray500)
                    Button(action: presenter.addManualTestCase) {
                    Text(L10n.Coding.Testcase.add)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color.appPurple)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appGray900)
            } else {
                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(Array(presenter.testCases.enumerated()), id: \.element.id) { index, testCase in
                                testCaseTab(index: index, testCase: testCase)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                    .background(Color.appGray900)

                    if selectedTestIndex < presenter.testCases.count {
                        testCaseContent(index: selectedTestIndex)
                    }
                }
            }
        }
        .frame(height: 180)
    }

    private func testCaseTab(index: Int, testCase: TestCase) -> some View {
        let isSelected = selectedTestIndex == index

        return Button(action: {
            selectedTestIndex = index
        }, label: {
            HStack(spacing: 4) {
                if let passed = testCase.passed {
                    Circle()
                        .fill(passed ? Color.appGreen : Color.appRed)
                        .frame(width: 6, height: 6)
                }

                Text(L10n.Coding.Testcase.caseFormat(index + 1))
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : Color.appGray500)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.appGray700 : Color.clear)
            )
        })
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive, action: {
                presenter.removeTestCase(at: index)
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }

    private func testCaseContent(index: Int) -> some View {
        let testCase = presenter.testCases[index]

        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Coding.Testcase.inputLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.appGray500)

                    TextField("Enter input...", text: Binding(
                        get: { testCase.input },
                        set: { presenter.updateTestCaseInput(at: index, input: $0) }
                    ), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

                VStack(alignment: .leading, spacing: 4) {
                Text(L10n.Coding.Testcase.expectedLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.appGray500)

                    TextField("Enter expected output...", text: Binding(
                        get: { testCase.expectedOutput },
                        set: { presenter.updateTestCaseExpectedOutput(at: index, output: $0) }
                    ), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(10)
        }
        .background(Color.appGray900)
    }
}
