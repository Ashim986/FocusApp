@testable import FocusApp
import Foundation

func makeQuestionContent(
    title: String,
    functionName: String,
    difficulty: String = "Medium",
    exampleTestcases: String = "[]",
    output: String = "[]"
) -> QuestionContent {
    QuestionContent(
        title: title,
        content: "<strong>Output:</strong> \(output)",
        exampleTestcases: exampleTestcases,
        sampleTestCase: "",
        difficulty: difficulty,
        codeSnippets: [
            "swift": "class Solution {\n    func \(functionName)(_ input: [Int]) -> [Int] {\n        return []\n    }\n}"
        ],
        metaData: functionMetaJSON(
            name: functionName,
            params: [("input", "integer[]")],
            returnType: "integer[]"
        )
    )
}

func functionMetaJSON(
    name: String,
    params: [(String, String)],
    returnType: String
) -> String {
    let paramsJSON = params
        .map { "{\"name\":\"\($0.0)\",\"type\":\"\($0.1)\"}" }
        .joined(separator: ",")
    return "{\"name\":\"\(name)\",\"params\":[\(paramsJSON)],\"return\":{\"type\":\"\(returnType)\"}}"
}
