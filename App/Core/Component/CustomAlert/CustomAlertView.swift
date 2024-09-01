import SwiftUI

// Represents a reusable view for displaying a custom error (e.g., price data unavailable)
struct CustomAlertView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let customAlert: CustomAlert
    
    var body: some View {
        VStack(alignment: .center, spacing: 10.0) {
            customAlert.image
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.secondaryPopColor)
            
            customAlert.message
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(BackgroundRoundedRectangleView())
    }
}
