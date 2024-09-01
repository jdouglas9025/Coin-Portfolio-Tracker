import SwiftUI

struct AddCoinView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var displayedView: PortfolioSelectionView.DisplayedView
    
    @State private var portfolioMiddleColumn: PortfolioMiddleColumn = .none
    
    @State private var selectedCoin: Coin?
    @State private var showEditCoinView = false
    
    private var customAlert: CustomAlert {
        if homeVM.status == .offline {
            return .serverOffline
        } else if homeVM.allCoins.isEmpty && !homeVM.portfolioSearchBarText.isEmpty {
            return .noMatches // No coins found -- search term without any matches
        }
        
        // Default (no alert) -- show as normal
        return .none
    }
    
    var body: some View {
        if !showEditCoinView {
            allCoins
        } else {
            // Show edit coin view
            if let selectedCoin = selectedCoin {
                EditCoinView(primaryVM: homeVM, displayedView: $displayedView, selectedPortfolioId: homeVM.selectedPortfolioId, selectedCoin: selectedCoin)
            }
        }
    }
    
    private var allCoins: some View {
        VStack(spacing: 10) {
            VStack {
                Text("Add Coin")
                    .font(.title)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
            }
            .padding(.horizontal)
            
            switch customAlert {
                case .deviceOffline, .serverOffline, .badData, .missingData:
                    CustomAlertView(customAlert: customAlert)
                        .padding([.horizontal, .bottom])
                
                case .none, .noMatches, .emptyPortfolio:
                    SearchBarView(searchBarText: $homeVM.topCoinsSearchBarText, padding: 10)
                    
                    PortfolioColumnsView(showSortOption: true, sortOption: $homeVM.topCoinsSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 10)
                    
                    // Use lazy to only load items as needed
                    LazyVStack(spacing: 10) {
                        ForEach(homeVM.allCoins, id: \.id) { coin in
                            CoinView(coin: coin, portfolioMiddleColumn: $portfolioMiddleColumn, showRank: true, padding: 7.5)
                                .onTapGesture {
                                    selectedCoin = coin
                                    
                                    withAnimation(.easeInOut) {
                                        showEditCoinView.toggle()
                                    }
                                }
                        }
                    }
            }
        }
    }
}
