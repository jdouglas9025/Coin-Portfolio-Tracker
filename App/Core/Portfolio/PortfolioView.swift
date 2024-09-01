import SwiftUI

// Main portfolio view -- home screen
struct PortfolioView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var landingVM: LandingViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    // Determines which middle column title/value to display (default is holding)
    @State private var portfolioMiddleColumn: PortfolioMiddleColumn = .holdings
    
    // Determines which set of summaries to show (default total value)
    @State private var showTotalValue = true
    @State private var showPortfolioOverviewView = false
    @State private var showProfitLossView = false
    
    // Selected coin for detailed view
    @State private var selectedCoin: Coin?
    @State private var showDetailView = false
    
    private var portfolioCoins: [Coin] {
        return homeVM.getPortfolioCoins(portfolioId: homeVM.selectedPortfolioId)
    }
    
    private var portfolioContainsHoldings: Bool {
        return homeVM.containsHoldings(portfolioId: homeVM.selectedPortfolioId)
    }
    
    private var portfolioSummaries: [any Summarizable] {
        return homeVM.getSummaries(portfolioId: homeVM.selectedPortfolioId)
    }
    
    private var isPortfolioEmpty: Bool {
        return homeVM.getPortfolioNumOfCoins(portfolioId: homeVM.selectedPortfolioId) == 0
    }
    
    private var customAlert: CustomAlert {
        if !networkMonitor.isOnline {
            return .deviceOffline
        } else if homeVM.status == .offline {
            return .serverOffline
        } else if isPortfolioEmpty && !homeVM.portfolioSearchBarText.isEmpty {
            return .noMatches // No coins found -- search term without any matches
        } else if isPortfolioEmpty {
            return .emptyPortfolio // Empty portfolio
        }
        
        return .none
    }
    
    var body: some View {
       ScrollView {
                // Check for an alert to determine data to display
                switch customAlert {
                    case .deviceOffline, .serverOffline, .badData, .missingData:
                        if !isPortfolioEmpty {
                            if portfolioContainsHoldings {
                                // Summaries (e.g., total value)
                                SummaryGroupView(summaries: portfolioSummaries, showFirstGroup: $showTotalValue)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            showTotalValue ? showPortfolioOverviewView.toggle() : showProfitLossView.toggle()
                                        }
                                    }
                            }
                            
                            SearchBarView(searchBarText: $homeVM.portfolioSearchBarText, padding: 10)
                            
                            CustomAlertView(customAlert: customAlert)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                            
                            // Show saved coins
                            PortfolioColumnsView(showSortOption: true, sortOption: $homeVM.portfolioSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 10)
                            portfolioCryptos
                        } else {
                            // No saved coins
                            CustomAlertView(customAlert: customAlert)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                        }
                    case .noMatches:
                        SearchBarView(searchBarText: $homeVM.portfolioSearchBarText, padding: 10)
                        
                        CustomAlertView(customAlert: customAlert)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                        
                    case .emptyPortfolio:
                        CustomAlertView(customAlert: customAlert)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                        
                    // Normal state
                    case .none:
                        if portfolioContainsHoldings {
                            // Summaries (e.g., total value)
                            SummaryGroupView(summaries: portfolioSummaries, showFirstGroup: $showTotalValue)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showTotalValue ? showPortfolioOverviewView.toggle() : showProfitLossView.toggle()
                                    }
                                }
                        }
                        
                        SearchBarView(searchBarText: $homeVM.portfolioSearchBarText, padding: 10)
                        
                        PortfolioColumnsView(showSortOption: true, sortOption: $homeVM.portfolioSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 10)
                        portfolioCryptos
                }
            }
            .padding(.vertical)
            .scrollIndicators(.hidden)
            .refreshable {
                homeVM.reloadData()
            }
            .sheet(isPresented: $landingVM.showPortfolioSelectionView, content: {
                PortfolioSelectionView()
                    .preferredColorScheme(themeVM.backgroundColorTheme)
                    .dynamicTypeSize(themeVM.textSizeTheme)
                    .environmentObject(themeVM)
            })
            .sheet(isPresented: $showDetailView, content: {
                DetailLoadingView(coin: $selectedCoin)
            })
            .sheet(isPresented: $showPortfolioOverviewView, content: {
                PortfolioOverviewView(portfolioOverviewVM: PortfolioOverviewViewModel(portfolio: portfolioCoins, overviewType: .totalValue, portfolioSummaries: portfolioSummaries))
                    .preferredColorScheme(themeVM.backgroundColorTheme)
                    .dynamicTypeSize(themeVM.textSizeTheme)
                    .environmentObject(homeVM)
                    .environmentObject(themeVM)
            })
            .sheet(isPresented: $showProfitLossView, content: {
                PortfolioOverviewView(portfolioOverviewVM: PortfolioOverviewViewModel(portfolio: portfolioCoins, overviewType: .profitLoss, portfolioSummaries: portfolioSummaries))
                    .preferredColorScheme(themeVM.backgroundColorTheme)
                    .dynamicTypeSize(themeVM.textSizeTheme)
                    .environmentObject(homeVM)
                    .environmentObject(themeVM)
            })
    }
}

extension PortfolioView {
    private var portfolioCryptos: some View {
        // Cannot use indices over actual items -- causes issue with images
        LazyVStack(spacing: 10) {
            ForEach(portfolioCoins) { coin in
                CoinView(coin: coin, portfolioMiddleColumn: $portfolioMiddleColumn, showRank: false, padding: 7.5)
                    .onTapGesture {
                        selectedCoin = coin
                        withAnimation(.easeInOut) {
                            showDetailView.toggle()
                        }
                    }
                    .background(.clear)
                    .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
                        switch value.translation.width {
                            //Left swipe (backward)
                            case (...0):
                                if portfolioMiddleColumn == .holdings {
                                    withAnimation(.easeInOut) {
                                        portfolioMiddleColumn = .costBasis
                                    }
                                } else if portfolioMiddleColumn == .costBasis {
                                    withAnimation(.easeInOut) {
                                        portfolioMiddleColumn = .profitLoss
                                    }
                                }
                                
                            // Right swipe (forward)
                            case (0...):
                                if portfolioMiddleColumn == .costBasis {
                                    withAnimation(.easeInOut) {
                                        portfolioMiddleColumn = .holdings
                                    }
                                } else if portfolioMiddleColumn == .profitLoss {
                                    withAnimation(.easeInOut) {
                                        portfolioMiddleColumn = .costBasis
                                    }
                                }
                                
                            // Shouldn't execute
                            default:
                                break
                        }
                    })
            }
        }
    }
}
