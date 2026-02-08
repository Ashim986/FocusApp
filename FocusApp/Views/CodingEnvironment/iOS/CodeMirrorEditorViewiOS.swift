#if os(iOS)
// CodeMirrorEditorViewiOS.swift
// FocusApp -- WKWebView wrapper that loads the CodeMirror 6 editor bundle

import FocusDesignSystem
import SwiftUI
import WebKit

struct CodeMirrorEditorViewiOS: UIViewRepresentable {
    @Binding var code: String
    let language: ProgrammingLanguage
    var isReadOnly: Bool = false
    var diagnostics: [CodeEditorDiagnostic] = []
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        userContentController.add(context.coordinator, name: "codeEditor")
        config.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false

        // Load the CodeMirror HTML from the bundle.
        // Try subdirectory first (folder reference), then root (Xcode flattens resources).
        let htmlURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: "CodeEditor"
        ) ?? Bundle.main.url(forResource: "index", withExtension: "html")

        if let htmlURL {
            webView.loadFileURL(
                htmlURL,
                allowingReadAccessTo: htmlURL.deletingLastPathComponent()
            )
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.isReady else { return }

        // Sync code changes from Swift to JavaScript
        if context.coordinator.lastKnownCode != code {
            let escaped = escapeForJavaScript(code)
            webView.evaluateJavaScript(
                "if (typeof editor !== 'undefined') { editor.setValue(\"\(escaped)\"); }"
            )
            context.coordinator.lastKnownCode = code
        }

        // Update language mode
        let langStr = language == .swift ? "swift" : "python"
        if context.coordinator.lastLanguage != langStr {
            webView.evaluateJavaScript(
                "if (typeof editor !== 'undefined') { editor.setLanguage('\(langStr)'); }"
            )
            context.coordinator.lastLanguage = langStr
        }

        // Update theme
        let themeStr = colorScheme == .dark ? "dark" : "light"
        if context.coordinator.lastTheme != themeStr {
            webView.evaluateJavaScript(
                "if (typeof editor !== 'undefined') { editor.setTheme('\(themeStr)'); }"
            )
            context.coordinator.lastTheme = themeStr
        }

        // Update read-only state
        if context.coordinator.lastReadOnly != isReadOnly {
            webView.evaluateJavaScript(
                "if (typeof editor !== 'undefined') { editor.setReadOnly(\(isReadOnly)); }"
            )
            context.coordinator.lastReadOnly = isReadOnly
        }

        // Update diagnostics
        if context.coordinator.lastDiagnostics != diagnostics {
            let diagJSON = diagnosticsToJSON(diagnostics)
            webView.evaluateJavaScript(
                "if (typeof editor !== 'undefined') { editor.setDiagnostics(\(diagJSON)); }"
            )
            context.coordinator.lastDiagnostics = diagnostics
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Diagnostics JSON

    private func diagnosticsToJSON(_ diags: [CodeEditorDiagnostic]) -> String {
        let items = diags.map { diag -> String in
            let escapedMsg = escapeForJavaScript(diag.message)
            return "{\"line\":\(diag.line),\"message\":\"\(escapedMsg)\"}"
        }
        return "[\(items.joined(separator: ","))]"
    }

    // MARK: - JavaScript String Escaping

    private func escapeForJavaScript(_ str: String) -> String {
        str
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: CodeMirrorEditorViewiOS
        var lastKnownCode: String = ""
        var lastLanguage: String = ""
        var lastTheme: String = ""
        var lastReadOnly: Bool = false
        var lastDiagnostics: [CodeEditorDiagnostic] = []
        var isReady = false

        init(_ parent: CodeMirrorEditorViewiOS) {
            self.parent = parent
        }

        // MARK: WKScriptMessageHandler

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard let dict = message.body as? [String: Any],
                  let type = dict["type"] as? String else { return }

            switch type {
            case "codeChange":
                if let code = dict["code"] as? String {
                    lastKnownCode = code
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.code = code
                    }
                }
            case "ready":
                isReady = true
                sendInitialState(to: message.webView)
            default:
                break
            }
        }

        // MARK: WKNavigationDelegate

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // The editor may or may not post a "ready" message.
            // Set initial state once navigation finishes as a fallback.
            if !isReady {
                isReady = true
                sendInitialState(to: webView)
            }
        }

        // MARK: - Helpers

        private func sendInitialState(to webView: WKWebView?) {
            guard let webView else { return }

            let escaped = parent.escapeForJavaScript(parent.code)
            let langStr = parent.language == .swift ? "swift" : "python"
            let themeStr = parent.colorScheme == .dark ? "dark" : "light"
            let diagJSON = parent.diagnosticsToJSON(parent.diagnostics)

            let script = """
                if (typeof editor !== 'undefined') {
                    editor.setValue("\(escaped)");
                    editor.setLanguage('\(langStr)');
                    editor.setTheme('\(themeStr)');
                    editor.setReadOnly(\(parent.isReadOnly));
                    editor.setDiagnostics(\(diagJSON));
                }
            """

            webView.evaluateJavaScript(script)

            lastKnownCode = parent.code
            lastLanguage = langStr
            lastTheme = themeStr
            lastReadOnly = parent.isReadOnly
            lastDiagnostics = parent.diagnostics
        }
    }
}

#Preview {
    CodeMirrorEditorViewiOS(
        code: .constant("func twoSum(_ nums: [Int], _ target: Int) -> [Int] {\n    // ...\n}"),
        language: .swift,
        diagnostics: [
            CodeEditorDiagnostic(line: 2, column: nil, message: "Missing return in function")
        ]
    )
    .frame(height: 300)
}
#endif
