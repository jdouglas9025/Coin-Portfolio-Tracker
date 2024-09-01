import Foundation

// Represents a Global Data entity parsed from JSON response
struct GlobalData: Identifiable, Codable {
    var id = UUID().uuidString
    
    // Market stats
    let activeCryptocurrencies: Int?
    let totalMarketCap: Double
    let totalVolume: Double
    let marketCapChangePercentage24H: Double
    
    // Market cap dominance stats
    let btcMarketCapPercentage: Double?
    let ethMarketCapPercentage: Double?
    
    // Need to mark what fields to parse explicitly using coding keys
    private enum CodingKeys: String, CodingKey {
        case activeCryptocurrencies
        case totalMarketCap
        case totalVolume
        case marketCapChangePercentage24H
        case btcMarketCapPercentage
        case ethMarketCapPercentage
    }
}
