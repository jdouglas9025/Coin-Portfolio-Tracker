import Foundation
import SwiftUI

// Used for storing selected text size theme in app storage (user defaults)
enum SelectedTextSizeTheme: String, CaseIterable {
    case small = "Small", medium = "Medium", large = "Large", xLarge = "xLarge", xxLarge = "xxLarge"
        
    
    var size: DynamicTypeSize {
        switch self {
            case .small:
                return .small
                
            // Default size
            case .medium:
                return .medium
                
            case .large:
                return .large
                
            case .xLarge:
                return .xLarge
                
            case .xxLarge:
                return .xxLarge
        }
    }
}

// Stores selected text color theme in app storage (user defaults)
// Conforms to String protocol so that it can be saved to app storage
enum SelectedTextColorTheme: String, CaseIterable {
    case system = "System", blue = "Blue", green = "Green", red = "Red"
        
    
    var theme: TextColorTheme {
        switch self {
            case .system:
                return System()
                
            case .blue:
                return Blue()
                
            case .green:
                return Green()
                
            case .red:
                return Red()
        }
    }
}

// Stores selected background color theme in app storage (user defaults)
// Independent of text color / size
enum SelectedBackgroundColorTheme: String, CaseIterable {
    case system = "System",
         light = "Light",
         dark = "Dark"
    
    // Used to display color based on saved background color theme -- uses color assets
    func color() -> Color {
        switch self {
            case .system:
                return (self == .dark) ? .dark : .light
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
    
    var theme: ColorScheme? {
        switch self {
            case .system:
                //System default
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
}
