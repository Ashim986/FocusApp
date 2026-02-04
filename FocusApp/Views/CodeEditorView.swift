import AppKit
import SwiftUI

struct CodeEditorView: NSViewRepresentable {
    @Binding var code: String
    let language: ProgrammingLanguage

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true

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

        textView.string = code
        context.coordinator.applySyntaxHighlighting()

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }

        if context.coordinator.language != language {
            context.coordinator.language = language
            textView.string = code
            context.coordinator.applySyntaxHighlighting()
            return
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
