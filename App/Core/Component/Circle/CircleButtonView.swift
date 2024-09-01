import SwiftUI

// Reusable component for a circular button wrapped around a specified icon
struct CircleButtonView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let iconName: String
    
    // Size of circle
    let width: Double
    let height: Double
    
    var body: some View {
        Image(systemName: iconName)
            .font(.headline)
            .foregroundColor(themeVM.textColorTheme.primaryText)
            .frame(width: width, height: height)
            .background {
                Circle()
                    .foregroundColor(themeVM.textColorTheme.background)
                    .shadow(color: themeVM.textColorTheme.primaryText,
                            radius: 1.75)
            }
    }
}
