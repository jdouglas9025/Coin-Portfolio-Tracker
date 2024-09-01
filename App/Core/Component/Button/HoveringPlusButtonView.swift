import SwiftUI

// Reusable component for a hovering plus button overlay at bottom of screen
// Used for adding new portfolio and coin to existing portfolio
struct HoveringPlusButtonView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                CircleButtonView(iconName: "plus", width: 60, height: 60)
                    .frame(alignment: .trailing)
                    .padding([.bottom, .trailing])
            }
        }
    }
}
