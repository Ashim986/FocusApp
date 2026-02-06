import AppKit
import SwiftUI

struct CodeEditorDiagnostic: Hashable {
    let line: Int
    let column: Int?
    let message: String
}

final class CodeEditorTextView: NSTextView {
    var onCommandR: (() -> Void)?
    var onCommandSlash: (() -> Void)?
    var onCommandT: (() -> Void)?
    var onDoubleClick: ((NSPoint) -> Bool)?

    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let hasCommandOnly = flags.contains(.command) && flags.subtracting([.command, .shift]).isEmpty
        if hasCommandOnly, let key = event.charactersIgnoringModifiers?.lowercased() {
            switch key {
            case "r":
                onCommandR?()
                return
            case "/":
                onCommandSlash?()
                return
            case "t":
                onCommandT?()
                return
            default:
                break
            }
        }
        super.keyDown(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2, let onDoubleClick {
            let point = convert(event.locationInWindow, from: nil)
            if onDoubleClick(point) {
                return
            }
        }
        super.mouseDown(with: event)
    }
}

struct CodeEditorView: NSViewRepresentable {
    @Binding var code: String
    let language: ProgrammingLanguage
    let diagnostics: [CodeEditorDiagnostic]
    let executionLine: Int?
    let isEditable: Bool
    let showsLineNumbers: Bool
    let onRun: (() -> Void)?

    init(
        code: Binding<String>,
        language: ProgrammingLanguage,
        diagnostics: [CodeEditorDiagnostic] = [],
        executionLine: Int? = nil,
        isEditable: Bool = true,
        showsLineNumbers: Bool = true,
        onRun: (() -> Void)? = nil
    ) {
        self._code = code
        self.language = language
        self.diagnostics = diagnostics
        self.executionLine = executionLine
        self.isEditable = isEditable
        self.showsLineNumbers = showsLineNumbers
        self.onRun = onRun
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = CodeEditorTextView.scrollableTextView()

        guard let textView = scrollView.documentView as? CodeEditorTextView else {
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
        textView.onCommandR = onRun
        textView.onCommandSlash = { [weak textView, weak coordinator = context.coordinator] in
            guard let textView, let coordinator else { return }
            coordinator.toggleComment(in: textView)
        }
        textView.onCommandT = { [weak textView, weak coordinator = context.coordinator] in
            guard let textView, let coordinator else { return }
            coordinator.insertTraceSnippet(in: textView)
        }
        textView.onDoubleClick = { [weak textView, weak coordinator = context.coordinator] point in
            guard let textView, let coordinator else { return false }
            return coordinator.handleBracketDoubleClick(at: point, in: textView)
        }

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
        guard let textView = nsView.documentView as? CodeEditorTextView else { return }
        textView.isEditable = isEditable
        textView.allowsUndo = isEditable
        textView.onCommandR = onRun
        textView.onCommandSlash = { [weak textView, weak coordinator = context.coordinator] in
            guard let textView, let coordinator else { return }
            coordinator.toggleComment(in: textView)
        }
        textView.onCommandT = { [weak textView, weak coordinator = context.coordinator] in
            guard let textView, let coordinator else { return }
            coordinator.insertTraceSnippet(in: textView)
        }
        textView.onDoubleClick = { [weak textView, weak coordinator = context.coordinator] point in
            guard let textView, let coordinator else { return false }
            return coordinator.handleBracketDoubleClick(at: point, in: textView)
        }

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
