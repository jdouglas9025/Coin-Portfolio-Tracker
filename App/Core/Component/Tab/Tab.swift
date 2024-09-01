import Foundation

// Represents a custom tab in a tab bar view (e.g., bottom tab bar on landing view)
enum Tab: String, CaseIterable {
    case portfolio = "Portfolio",
         topCoins = "Top Coins",
         market = "Market",
         future = "Future",
         settings = "Settings"
    
    // Returns the symbol as an unfilled symbol (not selected)
    var unfilledSymbol: String {
        switch self {
            case .portfolio:
                return "tray"
            case .topCoins:
                return "chart.bar"
            case .market:
                return "doc.richtext"
            case .future:
                return "binoculars"
            case .settings:
                return "gear.circle"
        }
    }
    
    // Returns the symbol as a filled symbol (if available)
    var filledSymbol: String {
        switch self {
            case .portfolio:
                return "tray.fill"
            case .topCoins:
                return "chart.bar.fill"
            case .market:
                return "doc.richtext.fill"
            case .future:
                return "binoculars.fill"
            case .settings:
                return "gear.circle.fill"
        }
    }
}
