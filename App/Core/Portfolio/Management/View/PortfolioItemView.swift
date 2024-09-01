import SwiftUI

// Represents the view for an individual portfolio in parent portfolio management/selection view
struct PortfolioItemView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    // Used to update data in other sub-views
    @Binding var displayedView: PortfolioSelectionView.DisplayedView
    @Binding var selectedPortfolioId: String
    @Binding var selectedPortfolioName: String
    
    let id: String
    let name: String
    let numOfCoins: Int
    let summaries: [any Summarizable]
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    
                Spacer()
                
                //Edit button
                Button(action: {
                    selectedPortfolioId = id
                    selectedPortfolioName = name
                    
                    withAnimation(.easeInOut) {
                        displayedView = .editPortfolio
                    }
                }, label: {
                    //For smaller buttons, use 40x40
                    CircleButtonView(iconName: "pencil", width: 40, height: 40)
                })
            }
            
            HStack {
                Text("Coins: " + String(numOfCoins))
                
                Spacer()
                
                // Active indicator
                Image(systemName: "star.fill")
                    // Set frame width to align with edit button
                    .frame(width: 40)
                    .opacity((isActive) ? 1.0 : 0.0)
            }
            .font(.caption)
            .foregroundStyle(themeVM.textColorTheme.secondaryText)
            
            HStack {
                if summaries.count > 0 {
                    // Total Value
                    SummaryView(summary: summaries[0])
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top)
            
            HStack(alignment: .firstTextBaseline) {
                if summaries.count >= 3 {
                    // Change and % Change
                    SummaryView(summary: summaries[1])
                        .multilineTextAlignment(.leading)
                    SummaryView(summary: summaries[2])
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
