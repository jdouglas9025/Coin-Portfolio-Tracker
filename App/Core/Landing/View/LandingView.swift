import SwiftUI

// Main container view that is loaded upon boot
struct LandingView: View {
    @State private var size = 0.75
    @State private var opacity = 0.75
    
    // User-selected theme from VM -- stored in app storage (user defaults)
    @StateObject private var themeVM = ThemeViewModel()
    // Primary view model throughout app
    @StateObject private var primaryVM = PrimaryViewModel()
    // Controls state data for tabs contained in this view
    @StateObject private var landingVM = LandingViewModel()
    // User device's internet connection
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @State private var selectedTab: Tab = .portfolio
    
    var body: some View {
        if landingVM.showSplashScreen || landingVM.showReloadScreen {
            // Initial boot or view reload screen
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                screen
            }
            .onAppear {
                if landingVM.showSplashScreen {
                    // Load screen for 3s to ensure API call completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation(.easeInOut) {
                            landingVM.showSplashScreen = false
                        }
                    }
                } else if landingVM.showReloadScreen {
                    // Allow all views to properly re-render
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) {
                        withAnimation(.easeInOut) {
                            landingVM.showReloadScreen = false
                        }
                    }
                }
            }
            .preferredColorScheme(themeVM.backgroundColorTheme)
            .dynamicTypeSize(themeVM.textSizeTheme)
        } else {
            NavigationStack {
                ZStack {
                    themeVM.textColorTheme.background
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Functionality (show selected view)
                        TabView(selection: $selectedTab) {
                            PortfolioView()
                                .tag(Tab.portfolio)
                                .onDisappear {
                                    primaryVM.portfolioSearchBarText = ""
                                }
                                
                            TopCoinsView()
                                .tag(Tab.topCoins)
                                .onDisappear {
                                    // Reset search bar text and sort
                                    primaryVM.topCoinsSearchBarText = ""
                                    primaryVM.topCoinsSortOption = .rank
                                }
                            
                            MarketView()
                                .tag(Tab.market)
                                .onDisappear {
                                    primaryVM.newsSearchBarText = ""
                                }
                            
                            FutureView()
                                .tag(Tab.future)
                            
                            SettingsView()
                                .tag(Tab.settings)
                        }
                        .onAppear() {
                            UITabBar.appearance().isHidden = true
                        }
                        
                        customTabBar
                    }
                }
                // Prevent tab bar from being pushed up by keyboard
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .navigationTitle(selectedTab == .portfolio ? primaryVM.getPortfolioName(portfolioId: primaryVM.selectedPortfolioId) : selectedTab.rawValue)
                .toolbar {
                    if selectedTab == .portfolio || selectedTab == .topCoins {
                        ToolbarItem(placement: .topBarTrailing) {
                            let isPortfolio = (selectedTab == .portfolio)
                            CircleButtonView(iconName: isPortfolio ? "slider.horizontal.3" : "info", width: 40, height: 40)
                                .padding(.top)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isPortfolio ? landingVM.showPortfolioSelectionView.toggle() : landingVM.showInfoView.toggle()
                                    }
                                }
                        }
                    }
                }
            }
            .preferredColorScheme(themeVM.backgroundColorTheme)
            .dynamicTypeSize(themeVM.textSizeTheme)
            .onAppear {
                setNavigationBarTitleTextColor()
            }
            // Add primary text color as an id to force reload of titles upon change -- must be after onAppear()
            .id(themeVM.textColorTheme.primaryText)
            .environmentObject(primaryVM)
            .environmentObject(themeVM)
            .environmentObject(landingVM)
            .environmentObject(networkMonitor)
        }
    }
}

extension LandingView {
    private var screen: some View {
        VStack(alignment: .center, spacing: 5.0) {
            Spacer()
            
            Image("LaunchLogo")
                .resizable()
                .frame(width: 300, height: 300)
                .padding(.bottom)
            
            Text("Coin Portfolio Tracker")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
            
            Text("Developed by Jacob Douglas")
                .font(.title3)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
            
            Spacer()
        }
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
            // Animate initial load screen on appear (duration 1/2 of load time)
            if landingVM.showSplashScreen {
                withAnimation(.easeInOut(duration: 1.5)) {
                    size = 1.0
                    opacity = 1.0
                }
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(alignment: .firstTextBaseline) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                let isSelectedTab = (selectedTab == tab)
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4.0) {
                    Image(systemName: isSelectedTab ? tab.filledSymbol : tab.unfilledSymbol)
                        .scaleEffect(isSelectedTab ? 1.2 : 1.0)
                        .font(.headline)
                        
                    Text(tab.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(isSelectedTab ? themeVM.textColorTheme.primaryText : themeVM.textColorTheme.secondaryText)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        selectedTab = tab
                    }
                }
                
                Spacer()
            }
        }
        .padding(10)
        .background(BackgroundRoundedRectangleView())
        .padding(.horizontal)
        // Small amount of padding from bottom to ensure proper view for iPhone SE
        .padding(.bottom, 5.0)
    }
    
    // Updates the global stack title text color upon reload to the new primary text color
    private func setNavigationBarTitleTextColor() {
        let uiColor = UIColor(themeVM.textColorTheme.primaryText)
        
        // Set appearance for inline and large size titles
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor : uiColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor : uiColor]
    }
}
