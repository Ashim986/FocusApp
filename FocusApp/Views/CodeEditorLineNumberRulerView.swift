import AppKit

final class CodeEditorLineNumberRulerView: NSRulerView {
    private weak var textView: NSTextView?
    private let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    private let gutterPadding: CGFloat = 6
    private var palette: CodeEditorThemeColors
    private var toolTipMessages: [NSView.ToolTipTag: String] = [:]

    var diagnostics: [CodeEditorDiagnostic] = [] {
        didSet {
            needsDisplay = true
        }
    }

    var executionLine: Int? {
        didSet {
            needsDisplay = true
        }
    }

    init(textView: NSTextView, palette: CodeEditorThemeColors) {
        self.textView = textView
        self.palette = palette
        super.init(scrollView: textView.enclosingScrollView ?? NSScrollView(), orientation: .verticalRuler)
        self.clientView = textView
        self.ruleThickness = 44
        self.wantsLayer = true
        self.layer?.backgroundColor = palette.background.cgColor
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }

        let text = textView.string as NSString
        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        let fullRange = NSRange(location: 0, length: text.length)
        let relativePoint = convert(NSPoint.zero, from: textView)
        let diagnosticsByLine = Dictionary(grouping: diagnostics, by: { $0.line })
        let currentExecutionLine = executionLine

        var lineNumber = 1
        var index = 0
        removeAllToolTips()
        toolTipMessages.removeAll()

        while index < text.length {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            if NSIntersectionRange(lineRange, charRange).length > 0 {
                let glyphRangeForLine = layoutManager.glyphRange(
                    forCharacterRange: lineRange,
                    actualCharacterRange: nil
                )
                let lineRect = layoutManager.boundingRect(
                    forGlyphRange: glyphRangeForLine,
                    in: textContainer
                )
                let yPosition = lineRect.minY + textView.textContainerInset.height + relativePoint.y

                let lineNumberString = "\(lineNumber)" as NSString
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: lineNumber == currentExecutionLine ? palette.execution : palette.lineNumber
                ]
                let size = lineNumberString.size(withAttributes: attributes)
                let x = ruleThickness - size.width - gutterPadding
                lineNumberString.draw(at: NSPoint(x: x, y: yPosition), withAttributes: attributes)

                if let diagnosticsForLine = diagnosticsByLine[lineNumber], !diagnosticsForLine.isEmpty {
                    let markerSize: CGFloat = 6
                    let markerX = gutterPadding
                    let markerY = yPosition + (lineRect.height - markerSize) / 2
                    let markerRect = NSRect(x: markerX, y: markerY, width: markerSize, height: markerSize)
                    let markerPath = NSBezierPath(ovalIn: markerRect)
                    palette.marker.setFill()
                    markerPath.fill()

                    let message = diagnosticsForLine
                        .map { $0.message }
                        .filter { !$0.isEmpty }
                        .joined(separator: "\n")
                    if !message.isEmpty {
                        let tag = addToolTip(markerRect, owner: self, userData: nil)
                        toolTipMessages[tag] = message
                    }
                }
            }
            index = NSMaxRange(lineRange)
            lineNumber += 1
        }

        let dividerPath = NSBezierPath()
        let x = ruleThickness - 1
        dividerPath.move(to: NSPoint(x: x, y: rect.minY))
        dividerPath.line(to: NSPoint(x: x, y: rect.maxY))
        palette.divider.setStroke()
        dividerPath.lineWidth = 1
        dividerPath.stroke()

        if fullRange.length == 0 {
            let lineNumberString = "1" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: palette.lineNumber
            ]
            let size = lineNumberString.size(withAttributes: attributes)
            let xPosition = ruleThickness - size.width - gutterPadding
            lineNumberString.draw(
                at: NSPoint(x: xPosition, y: relativePoint.y + textView.textContainerInset.height),
                withAttributes: attributes
            )
        }
    }

    func updatePalette(_ palette: CodeEditorThemeColors) {
        self.palette = palette
        layer?.backgroundColor = palette.background.cgColor
        needsDisplay = true
    }

    @objc func view(
        _ view: NSView,
        stringForToolTip tag: NSView.ToolTipTag,
        point: NSPoint,
        userData data: UnsafeMutableRawPointer?
    ) -> String {
        toolTipMessages[tag] ?? ""
    }
}
