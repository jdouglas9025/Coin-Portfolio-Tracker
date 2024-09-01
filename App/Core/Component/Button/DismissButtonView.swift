import SwiftUI

// Reusable component for a dismiss sheet button
struct DismissButtonView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    // Used to dismiss the open sheet and return to parent view
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundStyle(themeViewModel.textColorTheme.primaryText)
        })
    }
}
