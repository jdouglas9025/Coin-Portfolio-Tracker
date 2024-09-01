import SwiftUI

// Info. screen that displays details for last refresh times from server
struct LastRefreshView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    private var priceDataMessage: String {
        if primaryVM.allCoinsLastUpdated.isEmpty {
            return "Unable to determine last refresh for price data"
        } else {
            return "Price data last refreshed " + primaryVM.allCoinsLastUpdated
        }
    }
    
    private var trendingCoinsMessage: String {
        if primaryVM.trendingCoinsLastUpdated.isEmpty {
            return "Unable to determine last refresh for trending coins"
        } else {
            return "Trending coins last refreshed " + primaryVM.trendingCoinsLastUpdated
        }
    }
    
    private var newsMessage: String {
        if primaryVM.newsFeedLastUpdated.isEmpty {
            return "Unable to determine last refresh for news feed"
        } else {
            return "News feed last refreshed " + primaryVM.newsFeedLastUpdated
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    if !networkMonitor.isOnline {
                        CustomAlertView(customAlert: .deviceOffline)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    } else if primaryVM.status == .offline {
                        CustomAlertView(customAlert: .serverOffline)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(alignment: .leading) {
                            Text("Price Data")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text(priceDataMessage)
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                
                                Text("Price and global statistic data are refreshed every 25 to 30 minutes.")
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        VStack(alignment: .leading) {
                            Text("Trending Coins")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text(trendingCoinsMessage)
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                
                                Text("Data is refreshed every 6 hours.")
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        VStack(alignment: .leading) {
                            Text("News")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text(newsMessage)
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                
                                Text("Article headlines are refreshed every 60 minutes.")
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            }
                        }
                        .padding([.horizontal, .bottom])
                        
                        VStack(alignment: .leading) {
                            Text("Other")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 5.0) {
                                Text("Other types of data (e.g., coin descriptions) may not be refreshed for long periods of time due to low frequency of change.")
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            }
                        }
                        .padding([.horizontal, .bottom])
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.vertical)
            }
            
            .navigationTitle("Last Refresh Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButtonView()
                        .frame(width: 35, height: 35, alignment: .trailing)
                }
            }
        }
    }
}
