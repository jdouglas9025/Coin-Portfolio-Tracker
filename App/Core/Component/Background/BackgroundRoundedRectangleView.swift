import SwiftUI

// Represents a rounded rectangle to be used as a background for inputs/other fields
struct BackgroundRoundedRectangleView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    private let fill: AnyGradient?
    
    // Default
    init() {
        fill = nil
    }
    
    // Custom fill
    init(fill: AnyGradient) {
        self.fill = fill
    }
    
    var body: some View {
        if let fill {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(fill.opacity(0.70))
                .shadow(color: themeVM.textColorTheme.primaryText, radius: 1.5)
        } else {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(themeVM.textColorTheme.background)
                .shadow(color: themeVM.textColorTheme.primaryText, radius: 1.5)
        }
    }
}
