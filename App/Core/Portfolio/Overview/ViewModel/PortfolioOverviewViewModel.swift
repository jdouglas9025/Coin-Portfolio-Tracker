import Foundation
import SwiftUI

// Model for creating aggregate views of portfolio data -- either total value or P/L -- for various time periods
class PortfolioOverviewViewModel: ObservableObject {
    private let portfolio: [Coin]
    let overviewType: OverviewType
    private let portfolioSummaries: [any Summarizable]
    
    private let count: Int
    var dataAvailable = false
    
    // Approximate time of last sparkline data update for charts
    var sparklineLastUpdated: Date
    
    // Used for current overview section
    var currentSummaries: [any Summarizable] = []
    
    // Aggregate sparkline data for each time period
    var values7Days: [Double] = []
    var values5Days: [Double] = []
    var values3Days: [Double] = []
    var values1Days: [Double] = []
    
    // Summaries for each time period
    var summaries7Days: [any Summarizable] = []
    var summaries5Days: [any Summarizable] = []
    var summaries3Days: [any Summarizable] = []
    var summaries1Days: [any Summarizable] = []
    
    init(portfolio: [Coin], overviewType: OverviewType, portfolioSummaries: [any Summarizable]) {
        self.portfolio = portfolio
        self.overviewType = overviewType
        self.portfolioSummaries = portfolioSummaries
        
        // Get count and sparkline last updated (same all coins since same value added by server)
        count = portfolio.first?.sparklineIn7D?.price?.count ?? 0
        sparklineLastUpdated = (portfolio.first?.sparklineLastUpdated ?? "").asDate(dateType: .lastUpdated) 
        
        // No data available (at least for first coin)
        if count == 0 {
            return
        }
        
        // Get current overview summaries
        getCurrentSummaries()
        
        // Populate chart values
        updateChartValues()
        
        if !dataAvailable {
            return
        }
        
        // Populate summaries
        summaries7Days = getSummaries(values: values7Days)
        summaries5Days = getSummaries(values: values5Days)
        summaries3Days = getSummaries(values: values3Days)
        summaries1Days = getSummaries(values: values1Days)
    }
    
    // Gets the current summaries based on the view type
    private func getCurrentSummaries() {
        if overviewType == .totalValue || overviewType == .goal {
            if portfolioSummaries.count >= 3 {
                currentSummaries.append(portfolioSummaries[0])
                currentSummaries.append(portfolioSummaries[1])
                currentSummaries.append(portfolioSummaries[2])
            }
        } else {
            // Profit/Loss
            if portfolioSummaries.count >= 6 {
                currentSummaries.append(portfolioSummaries[3])
                currentSummaries.append(portfolioSummaries[4])
                currentSummaries.append(portfolioSummaries[5])
            }
        }
    }
    
    // Updates the chart values for 7, 5, 3, 1 day range
    private func updateChartValues() {
        //~7 days
        values7Days = [Double](repeating: 0.0, count: count)
        //~5 days
        values5Days = [Double](repeating: 0.0, count: count - 48)
        //~3 days
        values3Days = [Double](repeating: 0.0, count: count - 96)
        //~1 day
        values1Days = [Double](repeating: 0.0, count: count - 144)
        
        // Go through each coin in portfolio
        for coin in portfolio {
            let currentHoldings = coin.currentHoldings ?? 0.0
            
            if currentHoldings > 0.0 {
                // Update flag to reflect at least one coin with holdings
                dataAvailable = true
                
                let data = coin.sparklineIn7D?.price ?? []
                
                // Iterate and compute value for each period i
                for i in 0..<data.count {
                    let amount = overviewType == .totalValue ?
                        data[i] * currentHoldings :
                        (data[i] * currentHoldings) - (coin.costBasis ?? 0.0)
                    
                    values7Days[i] += amount
                    
                    //If most recent 5 days (from i = 48-167 inclusive), add to 5 days
                    if i >= 48 {
                        values5Days[i - 48] += amount
                        
                        //If most recent 3 days (from i = 96-167 inclusive), add to 3 days
                        if i >= 96 {
                            values3Days[i - 96] += amount
                            
                            //If most recent 1 day (from i = 144-167 inclusive), add to 1 day
                            if i >= 144 {
                                values1Days[i - 144] += amount
                            }
                        }
                    }
                }
            }
        }
    }

    // Gets overview summaries for the specified values (7, 5, 3, 1 days)
    private func getSummaries(values: [Double]) -> [any Summarizable] {
        let startingValue = values[0]
        let endingValue = values[values.count - 1]
        
        let high = values.max() ?? 0.0
        let low = values.min() ?? 0.0
        let range = high - low
        
        var change = endingValue - startingValue
        var changePercentage = ((endingValue - startingValue) / startingValue) * 100.0
        
        //Check if invalid number (may be due to data unavailable)
        if changePercentage.isNaN {
            changePercentage = 0.0
        }
        
        if change.isNaN {
            change = 0.0
        }
        
        return [
            CurrencySummary(title: "Starting Value", value: startingValue, isChange: false),
            CurrencySummary(title: "Ending Value", value: endingValue, isChange: false),
            CurrencySummary(title: "Change", value: change, isChange: true),
            PercentSummary(title: "% Change", value: changePercentage, isChange: true),
            
            CurrencySummary(title: "High", value: high, isChange: false),
            CurrencySummary(title: "Low", value: low, isChange: false),
            CurrencySummary(title: "Range", value: range, isChange: false),
        ]
    }
}

extension PortfolioOverviewViewModel {
    enum OverviewType: CaseIterable {
        case totalValue, profitLoss, goal
        
        var navigationTitle: String {
            switch self {
                case .totalValue:
                    return "Total Value Overview"
                case .profitLoss:
                    return "Profit/Loss Overview"
                case .goal:
                    return "Goal Progress"
            }
        }
        
        var chartTitle: String {
            switch self {
                case .totalValue:
                    return "Total Value Change"
                    
                case .profitLoss:
                    return "Profit/Loss Change"
                    
                case .goal:
                    return "Progress Change"
            }
        }
    }
}
