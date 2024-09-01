import SwiftUI

// Reusable component for a back button in nested views to return to parent view
// Logic to return to parent view defined with onTapGesture {} by caller
struct BackButtonView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    var body: some View {
        Image(systemName: "chevron.left")
            .font(.headline)
            .foregroundStyle(themeVM.textColorTheme.primaryText)
    }
}
