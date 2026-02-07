import FocusDesignSystem
import SwiftUI
import WebKit

#if os(macOS)
typealias PlatformWebViewRepresentable = NSViewRepresentable
#else
typealias PlatformWebViewRepresentable = UIViewRepresentable
#endif

struct LeetCodeLoginSheet: View {
    let onAuthCaptured: (LeetCodeAuthSession) -> Void
    let onClose: () -> Void
    @Environment(\.dsTheme) var theme

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                DSText(L10n.Settings.leetcodeLoginSheetTitle)
                    .font(.headline)
                    .foregroundColor(theme.colors.textPrimary)
                DSText(L10n.Settings.leetcodeLoginSheetBody)
                    .font(.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            LeetCodeLoginWebView { auth in
                onAuthCaptured(auth)
            }
            .frame(minWidth: 720, minHeight: 520)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.colors.border.opacity(0.6), lineWidth: 1)
            )

            HStack {
                Spacer()
                DSButton(L10n.Settings.close) {
                    onClose()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(16)
        .background(theme.colors.background)
    }
}

private struct LeetCodeLoginWebView: PlatformWebViewRepresentable {
    let onAuthCaptured: (LeetCodeAuthSession) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onAuthCaptured: onAuthCaptured)
    }

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: "https://leetcode.com/accounts/login/") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        // No-op
    }
    #else
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: "https://leetcode.com/accounts/login/") {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op
    }
    #endif

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let onAuthCaptured: (LeetCodeAuthSession) -> Void
        private var didCapture = false

        init(onAuthCaptured: @escaping (LeetCodeAuthSession) -> Void) {
            self.onAuthCaptured = onAuthCaptured
        }

        // swiftlint:disable:next implicitly_unwrapped_optional
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            captureAuthIfAvailable(webView)
        }

        private func captureAuthIfAvailable(_ webView: WKWebView) {
            guard !didCapture else { return }
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                guard !self.didCapture else { return }
                let sessionCookie = cookies.first { $0.name == "LEETCODE_SESSION" }
                let csrfCookie = cookies.first { $0.name == "csrftoken" }
                guard let session = sessionCookie?.value,
                      let csrf = csrfCookie?.value,
                      !session.isEmpty,
                      !csrf.isEmpty else {
                    return
                }
                self.didCapture = true
                let auth = LeetCodeAuthSession(
                    session: session,
                    csrfToken: csrf,
                    updatedAt: Date()
                )
                self.onAuthCaptured(auth)
            }
        }
    }
}
