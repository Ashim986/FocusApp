import AppKit
import SwiftUI

struct CodeEditorDiagnostic: Hashable {
    let line: Int
    let column: Int?
    let message: String
}

struct CodeEditorView: NSViewRepresentable {
    @Binding var code: String
    let language: ProgrammingLanguage
    let diagnostics: [CodeEditorDiagnostic]
    let executionLine: Int?
    let isEditable: Bool
    let showsLineNumbers: Bool

    init(
        code: Binding<String>,
        language: ProgrammingLanguage,
        diagnostics: [CodeEditorDiagnostic] = [],
        executionLine: Int? = nil,
        isEditable: Bool = true,
        showsLineNumbers: Bool = true
    ) {
        self._code = code
        self.language = language
        self.diagnostics = diagnostics
        self.executionLine = executionLine
        self.isEditable = isEditable
        self.showsLineNumbers = showsLineNumbers
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = isEditable

        let font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.font = font
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: NSColor.white
        ]

        textView.backgroundColor = NSColor(Color.appGray900)
        textView.textColor = NSColor.white
        textView.insertionPointColor = NSColor.white

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextCompletionEnabled = false
        textView.isGrammarCheckingEnabled = false

        textView.textContainerInset = NSSize(width: 8, height: 8)

        textView.delegate = context.coordinator
        context.coordinator.textView = textView
        context.coordinator.language = language
        context.coordinator.diagnostics = diagnostics
        context.coordinator.executionLine = executionLine

        if showsLineNumbers {
            let ruler = CodeEditorLineNumberRulerView(textView: textView)
            ruler.diagnostics = diagnostics
            ruler.executionLine = executionLine
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
            scrollView.verticalRulerView = ruler
        } else {
            scrollView.hasVerticalRuler = false
            scrollView.rulersVisible = false
            scrollView.verticalRulerView = nil
        }

        textView.string = code
        context.coordinator.applySyntaxHighlighting()

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        textView.isEditable = isEditable
        textView.allowsUndo = isEditable

        if context.coordinator.language != language {
            context.coordinator.language = language
            textView.string = code
            context.coordinator.applySyntaxHighlighting()
            return
        }

        context.coordinator.diagnostics = diagnostics
        context.coordinator.executionLine = executionLine
        context.coordinator.applyErrorHighlights()
        if showsLineNumbers {
            if let ruler = nsView.verticalRulerView as? CodeEditorLineNumberRulerView {
                ruler.diagnostics = diagnostics
                ruler.executionLine = executionLine
            } else {
                nsView.verticalRulerView?.needsDisplay = true
            }
        } else {
            nsView.hasVerticalRuler = false
            nsView.rulersVisible = false
            nsView.verticalRulerView = nil
        }

        if textView.string != code && !context.coordinator.isEditing {
            textView.string = code
            context.coordinator.applySyntaxHighlighting()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
