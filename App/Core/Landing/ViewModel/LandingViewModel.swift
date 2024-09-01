import Foundation

// Represents the VM for the landing page (tabs)
class LandingViewModel: ObservableObject {
    @Published var showPortfolioSelectionView = false
    @Published var showInfoView = false
    
    // Used upon initial boot
    @Published var showSplashScreen = true
    // Same as splash screen but used when reloading all views (changing text size/color)
    @Published var showReloadScreen = false
}
    
