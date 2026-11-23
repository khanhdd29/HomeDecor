//
//  InAppWebView.swift
//  HomeDecor
//
//  A WKWebView wrapped for SwiftUI — used to show hosted pages (e.g. the
//  Privacy Policy) inside the app instead of leaving to Safari. Tracks loading
//  and failure so the screen can overlay a spinner / error state.
//

import SwiftUI
import WebKit

@MainActor
final class WebViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var failed = false
}

struct InAppWebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var model: WebViewModel

    func makeCoordinator() -> Coordinator { Coordinator(model) }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func reload(_ webView: WKWebView) { webView.load(URLRequest(url: url)) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let model: WebViewModel
        init(_ model: WebViewModel) { self.model = model }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in model.isLoading = true; model.failed = false }
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in model.isLoading = false }
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in model.isLoading = false; model.failed = true }
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            Task { @MainActor in model.isLoading = false; model.failed = true }
        }
    }
}
