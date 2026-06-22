import SwiftUI
import WebKit

struct CustomerPaymentView: View {
    let orderId: String
    
    @State private var paymentStatus: PaymentStatus = .pending
    
    enum PaymentStatus {
        case pending
        case success
        case failed
    }

    var body: some View {
        VStack {
            if paymentStatus == .pending {
                // Dalam implementasi nyata, ini akan me-load URL Snap Midtrans
                // yang didapat dari respons API `/api/v1/orders/:id/payment`
                PaymentWebView(url: URL(string: "https://app.sandbox.midtrans.com/snap/v3/redirection/fake-token-\(orderId)")!) { urlString in
                    if urlString.contains("success") {
                        paymentStatus = .success
                    } else if urlString.contains("error") {
                        paymentStatus = .failed
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            } else {
                VStack(spacing: 24) {
                    Image(systemName: paymentStatus == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(paymentStatus == .success ? .green : .red)
                    
                    Text(paymentStatus == .success ? "Pembayaran Berhasil!" : "Pembayaran Gagal")
                        .font(.title2.bold())
                    
                    Text(paymentStatus == .success ? "Pesanan Anda sedang diteruskan ke kurir." : "Terjadi kesalahan saat memproses pembayaran. Silakan coba lagi.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        // TODO: Navigate to Tracking or Back to Home
                    } label: {
                        Text(paymentStatus == .success ? "Lacak Pesanan" : "Kembali")
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("CustomerPrimary"))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
        .navigationTitle("Pembayaran")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// WKWebView Wrapper
struct PaymentWebView: UIViewRepresentable {
    let url: URL
    let onURLChanged: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        
        // Load the Snap URL
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: PaymentWebView
        
        init(_ parent: PaymentWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let urlString = navigationAction.request.url?.absoluteString {
                // Simulate Midtrans callback handling
                if urlString.contains("midtrans.com") == false {
                    parent.onURLChanged(urlString)
                }
            }
            decisionHandler(.allow)
        }
    }
}

#Preview {
    CustomerPaymentView(orderId: "ORDER-123")
}
