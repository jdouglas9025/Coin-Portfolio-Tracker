import Foundation

// Represents a coin parsed from container from JSON response
struct Coin: Identifiable, Codable {
    let id: String // Unique identifier for each coin used throughout app
    let symbol: String
    let name: String
    let image: String
    
    let currentPrice: Double
    let marketCapRank: Int
    // Other properties may be null
    let marketCap: Double?
    let fullyDilutedValuation: Double?
    let totalVolume: Double?
    let high24H, low24H: Double?
    let priceChange24H, priceChangePercentage24H: Double?
    let marketCapChange24H, marketCapChangePercentage24H: Double?
    let circulatingSupply, totalSupply, maxSupply: Double?
    let ath, athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let sparklineIn7D: SparklineIn7D?
    let sparklineLastUpdated: String?
    
    let priceChangePercentage7D: Double?
    let priceChangePercentage14D: Double?
    let priceChangePercentage30D: Double?
    let priceChangePercentage1Y: Double?
    
    // 5 similar coins based on description -- only if description available
    let recommendedCoins: [String]?
    
    let blockTime: Int?
    let hashingAlgorithm: String?
    let description: String?
    let homepageUrl: String?
    let subredditUrl: String?
    let genesisDate: String?
    let positiveSentimentPercentage: Double?
    
    let currentHoldings: Double?
    var currentHoldingsValue: Double {
        // Dynamically calculate current holdings value based on holdings * price
        if currentHoldings == nil {
            return 0.0
        } else {
            return currentHoldings! * currentPrice
        }
    }
    
    let costBasis: Double?
    var averageCostPerCoin: Double {
        // Dynamically calculate average cost per coin based on cost basis / holdings
        if let costBasis = costBasis, let currentHoldings = currentHoldings {
            if currentHoldings != 0.0 {
                return costBasis / currentHoldings
            }
        }
        
        return 0.0
    }
    
    // Profit/loss (if cost basis available)
    var profitLossAmount: Double {
        if let costBasis = costBasis {
            return currentHoldingsValue - costBasis
        } else {
            return 0.0
        }
    }
    var profitLossPercentage: Double {
        if let costBasis = costBasis {
            if costBasis != 0.0 {
                // Calculate percent change by subtracting cost basis value from value and dividing by cost basis
                return ((currentHoldingsValue - costBasis) / costBasis) * 100.0
            }
        }
        
        return 0.0
    }
    
    init(id: String, symbol: String, name: String, image: String, currentPrice: Double, marketCap: Double?, marketCapRank: Double, fullyDilutedValuation: Double?, totalVolume: Double?, high24H: Double?, low24H: Double?, priceChange24H: Double?, priceChangePercentage24H: Double?, marketCapChange24H: Double?, marketCapChangePercentage24H: Double?, circulatingSupply: Double?, totalSupply: Double?, maxSupply: Double?, ath: Double?, athChangePercentage: Double?, athDate: String?, atl: Double?, atlChangePercentage: Double?, atlDate: String?, sparkLineIn7D: SparklineIn7D?, sparklineLastUpdated: String?, priceChangePercentage7D: Double?, priceChangePercentage14D: Double?, priceChangePercentage30D: Double?, priceChangePercentage1Y: Double?, recommendedCoins: [String]?, blockTime: Int?, hashingAlgorithm: String?, description: String?, homepageUrl: String?, subredditUrl: String?, genesisDate: String?, positiveSentimentPercentage: Double?, currentHoldings: Double?, costBasis: Double?) {
        self.id = id
        self.symbol = symbol.uppercased()
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = Int(marketCapRank)
        self.fullyDilutedValuation = fullyDilutedValuation
        self.totalVolume = totalVolume
        self.high24H = high24H
        self.low24H = low24H
        self.priceChange24H = priceChange24H
        self.priceChangePercentage24H = priceChangePercentage24H
        self.marketCapChange24H = marketCapChange24H
        self.marketCapChangePercentage24H = marketCapChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.ath = ath
        self.athChangePercentage = athChangePercentage
        self.athDate = athDate
        self.atl = atl
        self.atlChangePercentage = atlChangePercentage
        self.atlDate = atlDate
        self.sparklineIn7D = sparkLineIn7D
        self.sparklineLastUpdated = sparklineLastUpdated
        self.priceChangePercentage7D = priceChangePercentage7D
        self.priceChangePercentage14D = priceChangePercentage14D
        self.priceChangePercentage30D = priceChangePercentage30D
        self.priceChangePercentage1Y = priceChangePercentage1Y
        self.recommendedCoins = recommendedCoins
        self.blockTime = blockTime
        self.hashingAlgorithm = hashingAlgorithm
        self.description = description
        self.homepageUrl = homepageUrl
        self.subredditUrl = subredditUrl
        self.genesisDate = genesisDate
        self.positiveSentimentPercentage = positiveSentimentPercentage
        self.currentHoldings = currentHoldings
        self.costBasis = costBasis
    }
    
    // Constructs a new coin with an updated holdings/cost basis
    private init(coin: Coin, updatedHoldings: Double, updatedCostBasis: Double) {
        id = coin.id
        symbol = coin.symbol
        name = coin.name
        image = coin.image
        currentPrice = coin.currentPrice
        marketCap = coin.marketCap
        marketCapRank = coin.marketCapRank
        fullyDilutedValuation = coin.fullyDilutedValuation
        totalVolume = coin.totalVolume
        high24H = coin.high24H
        low24H = coin.low24H
        priceChange24H = coin.priceChange24H
        priceChangePercentage24H = coin.priceChangePercentage24H
        marketCapChange24H = coin.marketCapChange24H
        marketCapChangePercentage24H = coin.marketCapChangePercentage24H
        circulatingSupply = coin.circulatingSupply
        totalSupply = coin.totalSupply
        maxSupply = coin.maxSupply
        ath = coin.ath
        athChangePercentage = coin.athChangePercentage
        athDate = coin.athDate
        atl = coin.atl
        atlChangePercentage = coin.atlChangePercentage
        atlDate = coin.atlDate
        sparklineIn7D = coin.sparklineIn7D
        sparklineLastUpdated = coin.sparklineLastUpdated
        priceChangePercentage7D = coin.priceChangePercentage7D
        priceChangePercentage14D = coin.priceChangePercentage14D
        priceChangePercentage30D = coin.priceChangePercentage30D
        priceChangePercentage1Y = coin.priceChangePercentage1Y
        recommendedCoins = coin.recommendedCoins
        blockTime = coin.blockTime
        hashingAlgorithm = coin.hashingAlgorithm
        description = coin.description
        homepageUrl = coin.homepageUrl
        subredditUrl = coin.subredditUrl
        genesisDate = coin.genesisDate
        positiveSentimentPercentage = coin.positiveSentimentPercentage
        
        // Set new amounts
        currentHoldings = updatedHoldings
        costBasis = updatedCostBasis
    }
    
    // Update the user's current holdings and returns a new coin with the updated holding amount
    func updateCoin(updatedHoldings: Double, updatedCostBasis: Double) -> Coin {
        return Coin(coin: self, updatedHoldings: updatedHoldings, updatedCostBasis: updatedCostBasis)
    }
}

struct SparklineIn7D: Codable {
    let price: [Double]?
}


