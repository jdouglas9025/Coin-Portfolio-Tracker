import SwiftUI

// Represents a button to expand/collapse a collection of fields
struct ExpandButtonView: View {
    @Binding var showView: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                showView.toggle()
            }
        }, label: {
            HStack(spacing: 10) {
                CircleButtonView(iconName: (showView) ? "chevron.up" : "chevron.down", width: 40.0, height: 40.0)
            }
        })
    }
}
