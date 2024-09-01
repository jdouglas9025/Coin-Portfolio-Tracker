import Foundation

// Represents a trending coin from trending data response object parsed from JSON response
struct TrendingCoin: Identifiable, Codable {
    let id: String
    
    let name: String
    let symbol: String
    let marketCapRank: Int
    let largeImage: String
    let trendingScore: Int
    
    // May be nil
    let price: Double?
    let marketCap: Double?
    let volume: Double?
    let priceChangePercentage24H: Double?
    
    // Very likely to be nil
    let description: String?
}
