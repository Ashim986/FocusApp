import AppKit

extension CodeEditorView.Coordinator {
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(NSResponder.insertNewline(_:)):
            handleNewLine(textView: textView, range: textView.selectedRange(), text: textView.string)
            return true
        case #selector(NSResponder.insertTab(_:)):
            indentSelection(in: textView)
            return true
        case #selector(NSResponder.insertBacktab(_:)):
            outdentSelection(in: textView)
            return true
        case #selector(NSResponder.deleteBackward(_:)):
            return handleBackspace(in: textView)
        default:
            return false
        }
    }

    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        guard let replacementString = replacementString else { return true }

        if isInsertingMatchingBracket { return true }

        let text = textView.string
        let nsText = text as NSString

        if replacementString.count == 1, let char = replacementString.first {
            if let closingChar = bracketPairs[char] {
                if affectedCharRange.length > 0 {
                    wrapSelection(opening: char, closing: closingChar, in: textView, at: affectedCharRange)
                    return false
                }

                if char == "\"" || char == "'" {
                    if affectedCharRange.location < nsText.length {
                        let nextChar = nsText.substring(with: NSRange(location: affectedCharRange.location, length: 1))
                        if nextChar == String(char) {
                            textView.setSelectedRange(NSRange(location: affectedCharRange.location + 1, length: 0))
                            return false
                        }
                    }
                }

                insertMatchingBracket(opening: char, closing: closingChar, in: textView, at: affectedCharRange)
                return false
            }

            if closingBrackets.contains(char) {
                if affectedCharRange.location < nsText.length {
                    let nextChar = nsText.substring(with: NSRange(location: affectedCharRange.location, length: 1))
                    if nextChar == String(char) {
                        textView.setSelectedRange(NSRange(location: affectedCharRange.location + 1, length: 0))
                        return false
                    }
                }

                if shouldAlignClosingBracket(char, in: textView, at: affectedCharRange) {
                    return false
                }
            }
        }

        return true
    }
}
