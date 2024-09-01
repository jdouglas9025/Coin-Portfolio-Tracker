import SwiftUI
import WebKit

// Intermediate view that verifies the URL is not nil
struct BrowserLoadingView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var article: News?
    
    var body: some View {
        // Parse URL here to prevent having to unwrap inside next view
        if let article = article, let url = URL(string: article.url) {
            BrowserView(article: article, url: url)
                .preferredColorScheme(themeVM.backgroundColorTheme)
                .dynamicTypeSize(themeVM.textSizeTheme)
                .environmentObject(themeVM)
        }
    }
}

// View for loading an article in the in-app browser
private struct BrowserView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @State var article: News
    @State var url: URL
    
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                BrowserComponentView(url: url, isLoading: $isLoading)
                
                // Display loading view overlay while page is being loaded
                if isLoading {
                    ArticleLoadingView(article: $article)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButtonView()
                        .frame(width: 35, height: 35, alignment: .trailing)
                }
            }
        }
    }
}

// In-app browser component to use in the view itself
private struct BrowserComponentView: UIViewRepresentable {
    let url: URL
    
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Allow standard swipe gestures
        webView.allowsBackForwardNavigationGestures = true
        // Setup coordinator to handle events
        webView.navigationDelegate = context.coordinator
        
        webView.load(URLRequest(url: self.url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
            Coordinator(self)
    }
        
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: BrowserComponentView
        
        init(_ parent: BrowserComponentView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Initial loading has finished, but wait 3s for redirects to occur
            // Then, update parent view to reflect loading is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut) {
                    self.parent.isLoading = false
                }
            }
        }
    }
}
    
// Temporary view to display while web page is loading in browser
private struct ArticleLoadingView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var article: News
    
    var body: some View {
        ZStack {
            themeVM.textColorTheme.background
                .ignoresSafeArea()
            
            // Positioned in the middle
            VStack(spacing: 10) {
                // Display overview of the selected article
                NewsView(news: article)
                    // Enlarge since only single item
                    .scaleEffect(1.25)
                    .frame(width: 250)
                    .contentShape(Rectangle())
                    // Increase padding to accomdate larger content
                    .padding(40)
                    .background(BackgroundRoundedRectangleView())
                
                HStack(spacing: 10) {
                    Text("Loading")
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
            }
            .padding()
        }
    }
}

