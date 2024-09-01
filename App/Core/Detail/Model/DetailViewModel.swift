import Foundation
import SwiftUI

// Represents the VM for a detailed view for a selected coin
class DetailViewModel: ObservableObject {
    private let coin: Coin
    private let data: [Double]
    private let count: Int
    
    // General summaries
    var additionalSummaries: [any Summarizable] = []
    var historicalSummaries: [any Summarizable] = []
    var technicalSummaries: [any Summarizable] = []
    var socialSummaries: [any Summarizable] = []
    
    // Timeframe specific values
    var values7Days: [Double] = []
    var values5Days: [Double] = []
    var values3Days: [Double] = []
    var values1Days: [Double] = []
    
    var overviewSummaries7Days: [any Summarizable] = []
    var overviewSummaries5Days: [any Summarizable] = []
    var overviewSummaries3Days: [any Summarizable] = []
    var overviewSummaries1Days: [any Summarizable] = []
    
    init(coin: Coin) {
        self.coin = coin
        data = coin.sparklineIn7D?.price ?? []
        count = data.count
        
        // General summary items
        updateAdditionalSummaries()
        updateHistoricalSummaries()
        updateTechnicalSummaries()
        updateSocialSummaries()
        
        // No data available
        if count == 0 {
            return
        }
        
        // Populate chart values
        updateChartValues()
        
        // Get summaries
        overviewSummaries7Days = getOverviewSummaries(values: values7Days)
        overviewSummaries5Days = getOverviewSummaries(values: values5Days)
        overviewSummaries3Days = getOverviewSummaries(values: values3Days)
        overviewSummaries1Days = getOverviewSummaries(values: values1Days)
    }
    
    // Updates the chart values for 7, 5, 3, 1 day range with coin price
    private func updateChartValues() {
        // ~7 days
        values7Days = [Double](repeating: 0.0, count: count)
        // ~5 days
        values5Days = [Double](repeating: 0.0, count: count - 48)
        // ~3 days
        values3Days = [Double](repeating: 0.0, count: count - 96)
        // ~1 day
        values1Days = [Double](repeating: 0.0, count: count - 144)
        
        for i in 0..<count {
            values7Days[i] += data[i]
            
            // If most recent 5 days (from i = 48), add to 5 days
            if i >= 48 {
                values5Days[i - 48] += data[i]
                
                // If most recent 3 days (from i = 96), add to 3 days
                if i >= 96 {
                    values3Days[i - 96] += data[i]
                    
                    // If most recent 1 day (from i = 144), add to 1 day
                    if i >= 144 {
                        values1Days[i - 144] += data[i]
                    }
                }
            }
        }
    }
    
    private func getOverviewSummaries(values: [Double]) -> [any Summarizable] {
        let startingValue = values[0]
        let endingValue = values[values.count - 1]
        
        let high = values.max() ?? 0.0
        let low = values.min() ?? 0.0
        let range = high - low
        
        let change = endingValue - startingValue
        let changePercentage = ((endingValue - startingValue) / startingValue) * 100.0
        
        return [
            CurrencySummary(title: "Starting Value", value: startingValue, isChange: false),
            CurrencySummary(title: "Ending Value", value: endingValue, isChange: false),
            CurrencySummary(title: "Change", value: change, isChange: true),
            PercentSummary(title: "% Change", value: changePercentage, isChange: true),
            
            CurrencySummary(title: "High", value: high, isChange: false),
            CurrencySummary(title: "Low", value: low, isChange: false),
            CurrencySummary(title: "Range", value: range, isChange: false)
        ]
    }
    
    private func updateAdditionalSummaries() {
        var updated: [any Summarizable] = [
            IntSummary(title: "Rank", value: coin.marketCapRank, isCondensed: false)
        ]
        
        if let marketCap = coin.marketCap {
            updated.append(CondensedCurrencySummary(title: "Market Cap", value: marketCap))
        }
        
        if 
            let circulatingSupply = coin.circulatingSupply,
            let maxSupply = coin.maxSupply {
            updated.append(CondensedDoubleSummary(title: "Circulating Supply", value: circulatingSupply, isChange: false))
            updated.append(CondensedDoubleSummary(title: "Max Supply", value: maxSupply, isChange: false))
        }
        
        if let totalVolume = coin.totalVolume {
            updated.append(CondensedCurrencySummary(title: "Volume (24H)", value: totalVolume))
        }
        
        additionalSummaries = updated
    }
    
    private func updateHistoricalSummaries() {
        var updated: [any Summarizable] = []
        
        // Verify % changes available (may not be if new coin)
        if let priceChangePercentage30D = coin.priceChangePercentage30D {
            updated.append(PercentSummary(title: "1M Price % Change", value: priceChangePercentage30D, isChange: true))
            
            if let priceChangePercentage1Y = coin.priceChangePercentage1Y {
                updated.append(PercentSummary(title: "1Y Price % Change", value: priceChangePercentage1Y, isChange: true))
            }
        }
        
        updated.append(CurrencySummary(title: "All Time High", value: coin.ath ?? 0.0, isChange: false))
        updated.append(PercentSummary(title: "% Change", value: coin.athChangePercentage ?? 0.0, isChange: true))
        updated.append(DateSummary(title: "Date", value: coin.athDate ?? "", dateType: .coin))
        updated.append(CurrencySummary(title: "All Time Low", value: coin.atl ?? 0.0, isChange: false))
        updated.append(PercentSummary(title: "% Change", value: coin.atlChangePercentage ?? 0.0, isChange: true))
        updated.append(DateSummary(title: "Date", value: coin.atlDate ?? "", dateType: .coin))
        
        historicalSummaries = updated
    }
    
    private func updateTechnicalSummaries() {
        var updated: [any Summarizable] = []
        
        // Append available summaries
        if let blockTime = coin.blockTime {
            updated.append(StringSummary(title: "Block Time (Minutes)", value: String(blockTime)))
        }
        
        if let hashingAlgorithm = coin.hashingAlgorithm {
            updated.append(StringSummary(title: "Hash Algorithm", value: String(hashingAlgorithm)))
        }
        
        if let genesisDate = coin.genesisDate {
            updated.append(DateSummary(title: "Genesis Date", value: genesisDate, dateType: .genesisDate))
        }
        
        technicalSummaries = updated
    }
    
    private func updateSocialSummaries() {
        var updated: [any Summarizable] = []
        
        if let positiveSentimentPercentage = coin.positiveSentimentPercentage {
            updated.append(StringSummary(title: "Monthly Positive Sentiment", value: String(positiveSentimentPercentage) + "%"))
        }
        
        if let homepageUrl = coin.homepageUrl {
            updated.append(UrlSummary(title: "Homepage URL", value: homepageUrl, url: URL(string: homepageUrl)))
        }
        
        if let subredditUrl = coin.subredditUrl {
            updated.append(UrlSummary(title: "Subreddit URL", value: subredditUrl, url: URL(string: subredditUrl)))
        }
        
        socialSummaries = updated
    }
}
