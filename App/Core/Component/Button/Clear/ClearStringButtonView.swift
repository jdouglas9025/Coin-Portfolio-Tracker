import SwiftUI

// Reusable button to clear a string-based input field and hide keyboard
struct ClearStringButtonView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    // Text to clear
    @Binding var input: String
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                UIApplication.shared.hideKeyboard()
                input = ""
            }
        } label: {
            CircleButtonView(iconName: "xmark", width: 25.0, height: 25.0)
                .opacity((input.isEmpty) ? 0.0 : 1.0)
        }
    }
}
