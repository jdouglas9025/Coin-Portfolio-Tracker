import Foundation
import SwiftUI

// Theme VM throughout app; needs to be passed into any new view hierarchies (e.g., new sheet)
class ThemeViewModel: ObservableObject {
    // Background color theme
    @AppStorage("selectedBackgroundColorTheme", store: UserDefaults(suiteName: "group.com.jdouglas9025.coinportfoliotracker")) private var selectedBackgroundColorTheme: SelectedBackgroundColorTheme = .system
    // Text size theme -- default value of medium
    @AppStorage("selectedTextSizeTheme", store: UserDefaults(suiteName: "group.com.jdouglas9025.coinportfoliotracker")) private var selectedTextSizeTheme: SelectedTextSizeTheme = .medium
    // Text color theme (stored in user defaults) -- initial value of system
    @AppStorage("selectedTextColorTheme", store: UserDefaults(suiteName: "group.com.jdouglas9025.coinportfoliotracker")) private var selectedTextColorTheme: SelectedTextColorTheme = .system
    
    // Current themes -- values will be overridden in init() if different
    @Published var textSizeTheme: DynamicTypeSize = SelectedTextSizeTheme.medium.size
    @Published var textColorTheme: TextColorTheme = System()
    @Published var backgroundColorTheme: ColorScheme?
    
    init() {
        // Only execute if user default themes differ from system or default
        if selectedBackgroundColorTheme != .system {
            backgroundColorTheme = selectedBackgroundColorTheme.theme
        }
        
        if selectedTextSizeTheme != .medium {
            textSizeTheme = selectedTextSizeTheme.size
        }
        
        if selectedTextColorTheme != .system {
            textColorTheme = selectedTextColorTheme.theme
        }
    }
    
    // Increases the text size and saves the updated size to app storage
    func increaseTextSizeTheme() {
        var updatedSize: SelectedTextSizeTheme
        
        switch textSizeTheme {
            case SelectedTextSizeTheme.small.size:
                updatedSize = SelectedTextSizeTheme.medium
            case SelectedTextSizeTheme.medium.size:
                updatedSize = SelectedTextSizeTheme.large
            case SelectedTextSizeTheme.large.size:
                updatedSize = SelectedTextSizeTheme.xLarge
            case SelectedTextSizeTheme.xLarge.size:
                updatedSize = SelectedTextSizeTheme.xxLarge
            
            // xxLarge case
            default:
                updatedSize = SelectedTextSizeTheme.xxLarge
        }
        
        // Update published data and save change to app storage
        textSizeTheme = updatedSize.size
        selectedTextSizeTheme = updatedSize
    }
    
    // Decreases the text size and saves the updated size to app storage
    func decreaseTextSizeTheme() {
        var updatedSize: SelectedTextSizeTheme
        
        switch textSizeTheme {
            case SelectedTextSizeTheme.medium.size:
                updatedSize = SelectedTextSizeTheme.small
            case SelectedTextSizeTheme.large.size:
                updatedSize = SelectedTextSizeTheme.medium
            case SelectedTextSizeTheme.xLarge.size:
                updatedSize = SelectedTextSizeTheme.large
            case SelectedTextSizeTheme.xxLarge.size:
                updatedSize = SelectedTextSizeTheme.xLarge
            
            // small case
            default:
                updatedSize = SelectedTextSizeTheme.small
        }
        
        // Update published data and save change to app storage
        textSizeTheme = updatedSize.size
        selectedTextSizeTheme = updatedSize
    }
    
    // Saves the selected text color theme to app storage and updates the local property
    func updateTextColorTheme(selectedTextColorTheme: SelectedTextColorTheme) {
        if self.selectedTextColorTheme != selectedTextColorTheme {
            self.selectedTextColorTheme = selectedTextColorTheme
            textColorTheme = selectedTextColorTheme.theme
        }
    }
    
    // Saves the selected background color theme to app storage and updates the local property
    func updateBackgroundColorTheme(selectedBackgroundColorTheme: SelectedBackgroundColorTheme) {
        if self.selectedBackgroundColorTheme != selectedBackgroundColorTheme {
            self.selectedBackgroundColorTheme = selectedBackgroundColorTheme
            backgroundColorTheme = selectedBackgroundColorTheme.theme
        }
    }
    
    func getSelectedBackgroundColorTheme() -> SelectedBackgroundColorTheme {
        return selectedBackgroundColorTheme
    }
    
    func getSelectedTextSizeTheme() -> SelectedTextSizeTheme {
        return selectedTextSizeTheme
    }
    
    func getSelectedTextColorTheme() -> SelectedTextColorTheme {
        return selectedTextColorTheme
    }
}
