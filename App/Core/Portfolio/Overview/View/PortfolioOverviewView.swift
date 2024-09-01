import SwiftUI

// Used for displaying an overview of portfolio data -- either total value or P/L -- over various periods
struct PortfolioOverviewView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @ObservedObject var portfolioOverviewVM: PortfolioOverviewViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 10.0
    
    private var chartData: [Double] {
        switch homeVM.timeframeOption {
            case .sevenDays:
                portfolioOverviewVM.values7Days
            case .fiveDays:
                portfolioOverviewVM.values5Days
            case .threeDays:
                portfolioOverviewVM.values3Days
            case .oneDay:
                portfolioOverviewVM.values1Days
        }
    }
    
    private var summaryData: [any Summarizable] {
        switch homeVM.timeframeOption {
            case .sevenDays:
                portfolioOverviewVM.summaries7Days
            case .fiveDays:
                portfolioOverviewVM.summaries5Days
            case .threeDays:
                portfolioOverviewVM.summaries3Days
            case .oneDay:
                portfolioOverviewVM.summaries1Days
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    if homeVM.status == .offline {
                        CustomAlertView(customAlert: .serverOffline)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    } else if !portfolioOverviewVM.dataAvailable {
                        // No chart data available
                        CustomAlertView(customAlert: .missingData)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack {
                            // Current value, change, and % change
                            VStack {
                                Text("Current Overview")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        ForEach(portfolioOverviewVM.currentSummaries, id: \.id) { summary in
                                            SummaryView(summary: summary)
                                        }
                                    })
                            }
                            .padding(.vertical)
                            
                            VStack {
                                Text(homeVM.timeframeOption.rawValue + " " + portfolioOverviewVM.overviewType.chartTitle)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Last update time
                                Text("Last updated " + portfolioOverviewVM.sparklineLastUpdated.formatted(GeneralUtility.chartDateFormatter))
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                CustomAreaChartView(themeVM: themeVM, periodValues: chartData, periodEnd: portfolioOverviewVM.sparklineLastUpdated)
                                    .frame(height: 300)
                                    .padding(.top, 75)
                                    .padding(.trailing, 5)
                            }
                            .padding(.bottom)
                            
                            VStack {
                                Text("Period Overview")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Last update time
                                Text("Last updated " + portfolioOverviewVM.sparklineLastUpdated.formatted(GeneralUtility.chartDateFormatter))
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        ForEach(summaryData, id: \.id) { summary in
                                            SummaryView(summary: summary)
                                        }
                                    })
                            }
                            .padding(.bottom)
                        }
                        
                        HStack(spacing: 0) {
                            Text("Note: Price data may be delayed or unavailable. All provided values and calculations should only be considered an approximation.")
                        }
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
                .scrollIndicators(.hidden)
            }
            
            .navigationTitle(portfolioOverviewVM.overviewType.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        TimeframeMenuView()
                            .opacity(homeVM.status == .offline || !portfolioOverviewVM.dataAvailable ? 0.70 : 1.0)
                            .disabled(homeVM.status == .offline || !portfolioOverviewVM.dataAvailable ? true : false)
                        
                        DismissButtonView()
                            .frame(width: 35, height: 35, alignment: .trailing)
                    }
                }
            }
        }
    }
}
