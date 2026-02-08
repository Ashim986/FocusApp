import Foundation

struct CodeEditorDiagnostic: Hashable {
    let line: Int
    let column: Int?
    let message: String
}
