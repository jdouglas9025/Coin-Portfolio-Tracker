import SwiftUI

// Represents a group view for multiple summary items -- used for portfolio/top coins views for grouping summary items
struct SummaryGroupView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    // Data source
    let summaries: [any Summarizable]
    
    // Group to show (either first or second) -- default to first
    @Binding var showFirstGroup: Bool
    
    // Items to show depending on group selection
    private var range: Range<Int> {
        let count = summaries.count
        
        // If 3 items or less, only one group to show
        if count < 4 {
            return 0..<count
        }
        
        // Set range based on which group to show
        return (showFirstGroup) ? 0..<3 : 3..<count
    }
    
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                ForEach(range, id: \.self) { i in
                    // Construct generic summary view for this summary
                    SummaryView(summary: summaries[i])
                        .multilineTextAlignment(.leading)
                        //Use topLeading alignment on views to align all items to top left corner
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                }
            }
            
            // Indicator arrow for swipe direction (also clickable)
            Button(action: {
                withAnimation(.easeInOut) {
                    showFirstGroup.toggle()
                }
            }, label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: (showFirstGroup) ? 0.0 : 180.0))
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .padding(.trailing)
            })
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
            switch value.translation.width {
                case (...0):
                    if showFirstGroup {
                        withAnimation(.easeInOut) {
                            showFirstGroup.toggle()
                        }
                    }
                    
                case (0...):
                    if !showFirstGroup {
                        withAnimation(.easeInOut) {
                            showFirstGroup.toggle()
                        }
                    }
                    
                default: // Should not execute
                    break
            }
        })
    }
}
