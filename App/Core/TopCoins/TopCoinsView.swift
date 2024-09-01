import SwiftUI

// View for list of top 1000 coins by market cap
struct TopCoinsView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var landingVM: LandingViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    // Selected coin for detailed view
    @State private var selectedCoin: Coin?
    @State private var showDetailView = false
    
    @State private var showMarketCap = true
    
    // Hides middle column for this view since details not applicable
    @State private var portfolioMiddleColumn: PortfolioMiddleColumn = .none
    
    // Show message when no coins found (invalid search)
    private var showNoCoinsFoundMessage: Bool {
        return homeVM.allCoins.isEmpty && !homeVM.topCoinsSearchBarText.isEmpty
    }
    
    var body: some View {
        ScrollView {
                if !networkMonitor.isOnline {
                    CustomAlertView(customAlert: .deviceOffline)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                } else if homeVM.status == .offline {
                    CustomAlertView(customAlert: .serverOffline)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                } else {
                    // Global data summaries (e.g., total market cap)
                    SummaryGroupView(summaries: homeVM.globalDataSummaries, showFirstGroup: $showMarketCap)
                    
                    SearchBarView(searchBarText: $homeVM.topCoinsSearchBarText, padding: 10)
                    
                    if showNoCoinsFoundMessage {
                        CustomAlertView(customAlert: .noMatches)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    } else {
                        PortfolioColumnsView(showSortOption: true, sortOption: $homeVM.topCoinsSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 10)
                        allCryptos
                    }
                }
            }
            .padding(.vertical)
            .scrollIndicators(.hidden)
            .refreshable {
                homeVM.reloadData()
            }
            .sheet(isPresented: $landingVM.showInfoView, content: {
                LastRefreshView()
                    .preferredColorScheme(themeVM.backgroundColorTheme)
                    .dynamicTypeSize(themeVM.textSizeTheme)
                    .environmentObject(themeVM)
                    .environmentObject(homeVM)
            })
            .sheet(isPresented: $showDetailView, content: {
                DetailLoadingView(coin: $selectedCoin)
            })
    }
}

extension TopCoinsView {
    private var noCoinsFoundMessage: some View {
        HStack {
            Text("Looks like there isn't anything here.")
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }
    
    private var allCryptos: some View {
        LazyVStack(spacing: 10) {
            ForEach(homeVM.allCoins) { coin in
                CoinView(coin: coin, portfolioMiddleColumn: $portfolioMiddleColumn, showRank: true, padding: 7.5)
                    .onTapGesture {
                        selectedCoin = coin
                        withAnimation(.easeInOut) {
                            showDetailView.toggle()
                        }
                    }
            }
        }
    }
}
