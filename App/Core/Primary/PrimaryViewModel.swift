import Foundation
import Combine
import SwiftUI

// Primary view model for app
class PrimaryViewModel: ObservableObject {
    @Published var allCoins: [Coin] = []
    @Published var allCoinsLastUpdated = ""
    
    @Published var trendingCoins: [TrendingCoin] = []
    @Published var trendingCoinSummaries: [[any Summarizable]] = []
    @Published var trendingCoinsLastUpdated = ""
    
    // Global data summaries (displayed in top coins screen)
    @Published var globalDataSummaries: [any Summarizable] = []
    @Published var globalDataLastUpdated = ""
    
    @Published var newsFeed: [News] = []
    @Published var newsFeedLastUpdated = ""
    
    // Dictionary of user portfolio objects to tuple of coins, values, and summaries
    // K: portfolio id, V: tuple
    // Tuple: 0. coins array, 1. portfolio value, 2. portfolio cost basis, 3. summaries, 4. contains any holdings data (or just watchlist)
    @Published var portfolios: [String: ([Coin], Double, Double, [any Summarizable], Bool)] = [:]
    
    // User-selected portfolio (default is "0") -- persisted in app storage to ensure selected portfolio is active upon next boot
    @AppStorage("selectedPortfolioId", store: UserDefaults(suiteName: "group.com.glasengineering.simplecoinportfolio")) var selectedPortfolioId = "0"
    
    // Portfolio sort option (default is biggest holdings first) -- only sort option persisted since others are not related to any saved data
    // Need published value to re-render views upon change
    @Published var portfolioSortOption: SortOption = .reverseHoldings
    @AppStorage("selectedPortfolioSortOption", store: UserDefaults(suiteName: "group.com.glasengineering.simplecoinportfolio")) var selectedPortfolioSortOption: SortOption = .reverseHoldings

    // Filters in search bar
    @Published var portfolioSearchBarText = ""
    @Published var topCoinsSearchBarText = ""
    @Published var newsSearchBarText = ""
    
    // User-selected sorting options with default values - reset upon view disappear or session closure
    @Published var topCoinsSortOption: SortOption = .rank
    @Published var newsSortOption: NewsSortOption = .date
    @Published var timeframeOption: TimeframeOption = .sevenDays
    
    // Default to normal status
    @Published var status: Status = .normal
    
    private let marketDataApiService = MarketDataApiService()
    private let globalDataApiService = GlobalDataApiService()
    private let trendingApiService = TrendingDataApiService()
    private let managedDataService = ManagedDataService()
    private let newsFeedApiService = NewsFeedApiService()
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        // Update portfolio sort option to stored value
        portfolioSortOption = selectedPortfolioSortOption
        
        // Setup subs to listen for changes from their respective pubs throughout app lifecycle
        setupAllCoinsSub()
        setupGlobalDataSub()
        setupTrendingCoinsSub()
        setupManagedCoinsSub()
        setupNewsFeedSub()
    }
    
    private func setupAllCoinsSub() {
        marketDataApiService.$allCoins
            .combineLatest($topCoinsSearchBarText, $topCoinsSortOption, marketDataApiService.$lastUpdated)
            .map { (coins, filter, sort, lastUpdated) -> ([Coin], String) in
                var coins = coins
                
                // Update status based on response
                if coins.isEmpty {
                    self.status = .offline
                } else {
                    self.status = .normal
                }
                
                if !filter.isEmpty {
                    let filter = filter.lowercased()
                    
                    // Compare against name, symbol, and id
                    coins = coins.filter({ $0.name.lowercased().contains(filter)
                            || $0.symbol.lowercased().contains(filter) || $0.id.lowercased().contains(filter) })
                }
                
                self.sortCoins(sort: sort, coins: &coins)
                
                return (coins, lastUpdated)
            }
            .sink { [weak self] (coins, lastUpdated) in
                self?.allCoins = coins
                self?.allCoinsLastUpdated = lastUpdated
            }
            .store(in: &subscribers)
    }
    
    private func setupGlobalDataSub() {
        globalDataApiService.$globalData
            .combineLatest(globalDataApiService.$lastUpdated)
            // Takes in global data and maps into array of summaries
            .map { (globalData, lastUpdated) -> ([any Summarizable], String) in
                let globalData = globalData
                
                var summaries: [any Summarizable] = []
                
                // Create summary items
                let totalMarketCap = CondensedCurrencySummary(title: "Total Market Cap", value: globalData?.totalMarketCap ?? 0.0)
                let percentChange = PercentSummary(title: "% Change", value: globalData?.marketCapChangePercentage24H ?? 0.0, isChange: true)
                let totalVolume = CondensedCurrencySummary(title: "Total Volume", value: globalData?.totalVolume ?? 0.0)
                
                let btcMarketCapDominance = PercentSummary(title: "BTC Dominance", value: globalData?.btcMarketCapPercentage ?? 0.0, isChange: false)
                let ethMarketCapDominance = PercentSummary(title: "ETH Dominance", value: globalData?.ethMarketCapPercentage ?? 0.0, isChange: false)
                let activeCoins = IntSummary(title: "Active Coins", value: globalData?.activeCryptocurrencies ?? 0, isCondensed: true)
                
                summaries.append(totalMarketCap)
                summaries.append(percentChange)
                summaries.append(totalVolume)
                summaries.append(btcMarketCapDominance)
                summaries.append(ethMarketCapDominance)
                summaries.append(activeCoins)
                
                
                return (summaries, lastUpdated)
            }
            .sink { [weak self] (summaries, lastUpdated) in
                self?.globalDataSummaries = summaries
                self?.globalDataLastUpdated = lastUpdated
            }
            .store(in: &subscribers)
    }
    
    private func setupTrendingCoinsSub() {
        trendingApiService.$trendingCoins
            .combineLatest(trendingApiService.$lastUpdated)
            .map { (coins, lastUpdated) -> ([TrendingCoin], String, [[any Summarizable]]) in
                var summaryContainer: [[any Summarizable]] = []
                
                // Create summaries for each coin
                for coin in coins {
                    // Result for this coin
                    var summaryResult: [any Summarizable] = []
                    
                    // Create components
                    let value = CurrencySummary(title: "Price", value: coin.price ?? 0.0, isChange: false)
                    let change = PercentSummary(title: "% Change", value: coin.priceChangePercentage24H ?? 0.0, isChange: true)
                    let marketCap = CondensedCurrencySummary(title: "Market Cap", value: coin.marketCap ?? 0.0)
                    let volume = CondensedCurrencySummary(title: "Volume", value: coin.volume ?? 0.0)
                    
                    summaryResult.append(value)
                    summaryResult.append(change)
                    summaryResult.append(marketCap)
                    summaryResult.append(volume)
                    
                    summaryContainer.append(summaryResult)
                }
                
                return (coins, lastUpdated, summaryContainer)
            }
            .sink { [weak self] (coins, lastUpdated, summaryContainer) in
                self?.trendingCoins = coins
                self?.trendingCoinsLastUpdated = lastUpdated
                self?.trendingCoinSummaries = summaryContainer
            }
            .store(in: &subscribers)
    }
    
    private func setupManagedCoinsSub() {
        // Updates the user's data for each portfolio from core data when there is a change to all coins
        // Subscribe to actual source data to prevent modifying when filtering/sorting local data
        marketDataApiService.$allCoins
            .combineLatest(managedDataService.$portfolios, $portfolioSortOption, $portfolioSearchBarText)
            .map { (liveCoins, managedPortfolios, sort, filter) -> [String: ([Coin], Double, Double, [any Summarizable], Bool)] in
                // Check if live coins is empty (load saved prices) -- do before filtering to prevent displaying old data when filtering
                let unableToGetFreshData = liveCoins.isEmpty
                
                // Update map to return
                var result: [String: ([Coin], Double, Double, [any Summarizable], Bool)] = [:]
                
                // Update each portfolio's data with coin prices
                for managedPortfolio in managedPortfolios {
                    // Current portfolio's managed coins
                    let managedCoins = managedPortfolio.managedCoins?.allObjects as? [ManagedCoin] ?? []
                    
                    // Temporary container for this portfolio iteration
                    var coinResult: [Coin] = []
                    
                    // If no fresh data available, use old data; else, use fresh data
                    if unableToGetFreshData {
                        for managedCoin in managedCoins {
                            let coin = Coin(id: managedCoin.id ?? "", symbol: managedCoin.symbol ?? "", name: managedCoin.name ?? "", image: managedCoin.image ?? "", currentPrice: managedCoin.lastPrice, marketCap: nil, marketCapRank: Double(managedCoin.marketCapRank), fullyDilutedValuation: nil, totalVolume: nil, high24H: nil, low24H: nil, priceChange24H: nil, priceChangePercentage24H: nil, marketCapChange24H: nil, marketCapChangePercentage24H: nil, circulatingSupply: nil, totalSupply: nil, maxSupply: nil, ath: nil, athChangePercentage: nil, athDate: nil, atl: nil, atlChangePercentage: nil, atlDate: nil, sparkLineIn7D: nil, sparklineLastUpdated: nil, priceChangePercentage7D: nil, priceChangePercentage14D: nil, priceChangePercentage30D: nil, priceChangePercentage1Y: nil, recommendedCoins: nil, blockTime: nil, hashingAlgorithm: nil, description: nil, homepageUrl: nil, subredditUrl: nil, genesisDate: nil, positiveSentimentPercentage: nil, currentHoldings: managedCoin.holdingAmount, costBasis: managedCoin.costBasis)
                            
                            coinResult.append(coin)
                        }
                    } else {
                        for managedCoin in managedCoins {
                            // Get corresponding live coin
                            if let liveCoin = liveCoins.first(where: { $0.id == managedCoin.id }) {
                                // Add a new coin to result with the refreshed data and holding amount/cost basis
                                coinResult.append(liveCoin.updateCoin(updatedHoldings: managedCoin.holdingAmount, updatedCostBasis: managedCoin.costBasis))
                                
                                // Update saved, managed coin with latest data (price, image, rank) for offline mode
                                self.managedDataService.refreshManagedCoin(managedCoin: managedCoin, coin: liveCoin)
                            }
                        }
                    }
                    
                    if !filter.isEmpty {
                        let term = filter.lowercased()
                        
                        // Compare against name, symbol, id
                        coinResult = coinResult.filter({
                                $0.name.lowercased().contains(term) ||
                                $0.symbol.lowercased().contains(term) ||
                                $0.id.lowercased().contains(term)
                            })
                    }
                    
                    self.sortCoins(sort: sort, coins: &coinResult)
                    // Update app storage with new sort option
                    self.selectedPortfolioSortOption = sort
                    
                    // Check whether portfolio has holdings data or just a watchlist
                    let containsHoldings = (coinResult
                        .map { $0.currentHoldings ?? 0.0 }
                        .reduce(0.00, +)
                    ) > 0.0
                    
                    if containsHoldings {
                        // Container for portfolio's summaries
                        var summaryResult: [any Summarizable] = []
                        
                        let currentTotalValue = coinResult
                            .map { $0.currentHoldingsValue }
                            .reduce(0.00, +)
                        
                        let currentCostBasis = coinResult
                            .map { $0.costBasis ?? 0.0 }
                            .reduce(0.00, +)
                        
                        let currentProfitLoss = coinResult
                            .map { $0.profitLossAmount }
                            .reduce(0.00, +)
                        
                        // Calculate previous total value over 24 hours
                        let previousTotalValue = coinResult
                            .map { coin in
                                let currentValue = coin.currentHoldingsValue
                                let percentChange = (coin.priceChangePercentage24H ?? 0.0) / 100.0
                                let previousValue = currentValue / (1 + percentChange)
                                
                                return previousValue
                            }
                            .reduce(0.00, +)
                        
                        // Calculate previous P/L over 24 hours
                        let previousProfitLoss = coinResult
                            .map { coin in
                                let currentValue = coin.profitLossAmount
                                let percentChange = (coin.priceChangePercentage24H ?? 0.0) / 100.0
                                let previousValue = currentValue / (1 + percentChange)
                                
                                return previousValue
                            }
                            .reduce(0.00, +)
                        
                        var totalValueChange = currentTotalValue - previousTotalValue
                        var profitLossChange = currentProfitLoss - previousProfitLoss
                        
                        // Calculate percent change by subtracting old value from new value and dividing by old value
                        var totalValuePercentChange = ((currentTotalValue - previousTotalValue) / previousTotalValue) * 100.0
                        var profitLossPercentChange = ((currentProfitLoss - previousProfitLoss) / previousProfitLoss) * 100.0
                        
                        // Check if invalid number (may be due to data unavailable)
                        if totalValuePercentChange.isNaN || totalValueChange.isNaN {
                            totalValuePercentChange = 0.0
                            totalValueChange = 0.0
                        }
                        
                        if profitLossPercentChange.isNaN || profitLossChange.isNaN {
                            profitLossPercentChange = 0.0
                            profitLossChange = 0.0
                        }
                        
                        // First group summaries
                        let totalValueSummary = CurrencySummary(title: "Total Value", value: currentTotalValue, isChange: false)
                        let totalValueChangeSummary = CurrencySummary(title: "Change", value: totalValueChange, isChange: true)
                        let totalValuePercentChangeSummary = PercentSummary(title: "% Change", value: totalValuePercentChange, isChange: true)
                        
                        // Second group summaries
                        let profitLossValueSummary = CurrencySummary(title: "Total Profit/Loss", value: currentProfitLoss, isChange: true)
                        let profitLossChangeSummary = CurrencySummary(title: "Change", value: profitLossChange, isChange: true)
                        let profitLossPercentChangeSummary = PercentSummary(title: "% Change", value: profitLossPercentChange, isChange: true)
                        
                        summaryResult.append(totalValueSummary)
                        summaryResult.append(totalValueChangeSummary)
                        summaryResult.append(totalValuePercentChangeSummary)
                        
                        summaryResult.append(profitLossValueSummary)
                        summaryResult.append(profitLossChangeSummary)
                        summaryResult.append(profitLossPercentChangeSummary)
                        
                        // Add entry into map
                        result[String(managedPortfolio.portfolioId ?? "0")] = (coinResult, currentTotalValue, currentCostBasis, summaryResult, containsHoldings)
                    } else {
                        // Add entry with default values and no summaries into map
                        result[String(managedPortfolio.portfolioId ?? "0")] = (coinResult, 0.00, 0.00, [], containsHoldings)
                    }
                }
                
                return result
            }
            .sink { [weak self] result in
                self?.portfolios = result
            }
            .store(in: &subscribers)
    }
    
    private func setupNewsFeedSub() {
        newsFeedApiService.$newsFeed
            .combineLatest($newsSortOption, newsFeedApiService.$lastUpdated, $newsSearchBarText)
            .map { (feed, sortOption, lastUpdated, filter) -> ([News], String) in
                var feed = feed
                
                if !filter.isEmpty {
                    let filter = filter.lowercased()
                    
                    // Compare against title, publisher name
                    feed = feed.filter({ $0.title.lowercased().contains(filter)
                        || $0.publisherName.lowercased().contains(filter) })
                }
                
                self.sortNewsFeed(sort: sortOption, news: &feed)
                
                return (feed, lastUpdated)
            }
            .sink { [weak self] (result, lastUpdated) in
                self?.newsFeed = result
                self?.newsFeedLastUpdated = lastUpdated
            }
            .store(in: &subscribers)
    }
    
    // Sorts the coins array in-place
    private func sortCoins(sort: SortOption, coins: inout [Coin]) {
        switch sort {
            case .rank:
                return coins.sort(by: { $0.marketCapRank < $1.marketCapRank })
                
            case .reverseRank:
                return coins.sort(by: { $0.marketCapRank > $1.marketCapRank })
                
            case .holdings:
                return coins.sort(by: { $0.currentHoldingsValue < $1.currentHoldingsValue })
                
            case .reverseHoldings:
                return coins.sort(by: { $0.currentHoldingsValue > $1.currentHoldingsValue })
                
            case .costBasis:
                return coins.sort(by: { $0.costBasis ?? 0.0 < $1.costBasis ?? 0.0 })
                
            case .reverseCostBasis:
                return coins.sort(by: { $0.costBasis ?? 0.0 > $1.costBasis ?? 0.0 })
                
            case .percentChange:
                return coins.sort(by: { $0.priceChangePercentage24H ?? 0.0 < $1.priceChangePercentage24H ?? 0.0 })
                
            case .reversePercentChange:
                return coins.sort(by: { $0.priceChangePercentage24H ?? 0.0 > $1.priceChangePercentage24H ?? 0.0 })
        }
    }
    
    // Sorts the news array in-place
    // Date needs to already be parsed -- parsing in this function causes severe bottleneck
    private func sortNewsFeed(sort: NewsSortOption, news: inout [News]) {
        switch sort {
            case .date:
                return news.sort(by: { $0.publishedDate.compare($1.publishedDate) == .orderedDescending })
                
            case .reverseDate:
                return news.sort(by: { $0.publishedDate.compare($1.publishedDate) == .orderedAscending })
        }
    }
}

extension PrimaryViewModel {
    // Used for sorting of coins in portfolio views
    enum SortOption: String, CaseIterable {
        case rank = "Rank", reverseRank = "Reverse Rank", holdings = "Holdings", reverseHoldings = "Reverse Holdings", costBasis = "Cost Basis", reverseCostBasis = "Reverse Cost Basis", percentChange = "Percent Change", reversePercentChange = "Reverse Percent Change"
        
        var name: Text {
            switch self {
                case .rank, .reverseRank:
                    return Text("Rank")
                    
                case .holdings, .reverseHoldings:
                    return Text("Holdings")
                    
                case .costBasis, .reverseCostBasis:
                    return Text("Cost Basis")
                    
                case .percentChange, .reversePercentChange:
                    return Text("Percent Change")
            }
        }
        
        var order: Text {
            switch self {
                case .holdings, .costBasis:
                    return Text("Smallest to Largest")
                    
                case .rank:
                    return Text("Top to Bottom")
                    
                case .percentChange:
                    return Text("Biggest Losses First")
                    
                case .reverseHoldings, .reverseCostBasis:
                    return Text("Largest to Smallest")
                    
                case .reverseRank:
                    return Text("Bottom to Top")
                    
                case .reversePercentChange:
                    return Text("Biggest Gains First")
            }
        }
        
        var image: Image {
            switch self {
                case .rank, .holdings, .costBasis, .percentChange:
                    return Image(systemName: "chevron.up")
                    
                case .reverseRank, .reverseHoldings, .reverseCostBasis, .reversePercentChange:
                    return Image(systemName: "chevron.down")
            }
        }
    }
    
    // Used for sorting of news items
    enum NewsSortOption: String, CaseIterable {
        case date = "Date (DESC)", reverseDate = "Date (ASC)"
        
        var text: Text {
            switch self {
                case .date:
                    return Text("Latest First")
                    
                case .reverseDate:
                    return Text("Oldest First")
            }
        }
        
        var image: Image {
            if self.rawValue.contains("ASC") {
                return Image(systemName: "chevron.up")
            } else {
                return Image(systemName: "chevron.down")
            }
        }
    }
    
    // Used for changing timeframe for charts/overviews -- stored in primary VM to enable a change to show throughout app
    enum TimeframeOption: String, CaseIterable {
        case oneDay = "1 Day", threeDays = "3 Day", fiveDays = "5 Day", sevenDays = "7 Day"
    }
    
    // Used to check if device/server is offline or not (normal) -- does not consider errors due to filtering or other actions
    enum Status {
        case offline, normal
    }
    
    // Refreshes live data by calling various dynamic services on server
    func reloadData() {
        marketDataApiService.getAllCoins()
        globalDataApiService.getGlobalData()
        trendingApiService.getTrendingCoins()
        newsFeedApiService.getNews()
    }
    
    // Coin functions:
    // Updates user's core data with the specified coin data for the selected portfolio
    func updateCoin(coin: Coin, holdingAmount: Double, costBasis: Double, isWatched: Bool, selectedCoinNote: String) {
        managedDataService.updateCoin(portfolioId: selectedPortfolioId, coin: coin, holdingAmount: holdingAmount, costBasis: costBasis, isWatched: isWatched, selectedCoinNote: selectedCoinNote)
    }
    
    func deleteCoin(coin: Coin) {
        managedDataService.deleteCoin(portfolioId: selectedPortfolioId, coin: coin)
    }
    
    func isWatchedCoin(coin: Coin) -> Bool {
        return managedDataService.isWatchedCoin(portfolioId: selectedPortfolioId, coin: coin)
    }
    
    func updateCoinNote(coin: Coin, note: String) {
        managedDataService.updateCoinNote(portfolioId: selectedPortfolioId, coin: coin, note: note)
    }
    
    func getCoinNote(coin: Coin) -> String? {
        return managedDataService.getCoinNote(portfolioId: selectedPortfolioId, coin: coin)
    }
    
    // Returns a list of recommended coins for the current portfolio
    func getRecommendedCoins() -> [Coin] {
        // Keep track of already seen ids to prevent duplicates
        var seen = Set<String>()
        var recommendedCoins: [Coin] = []
        
        let portfolioCoins = getPortfolioCoins(portfolioId: selectedPortfolioId)
        
        // Prevent recommending coins already in portfolio
        for portfolioCoin in portfolioCoins {
            seen.insert(portfolioCoin.id)
        }
        
        // Get recommendations
        for portfolioCoin in portfolioCoins {
            for recommendedCoinId in portfolioCoin.recommendedCoins ?? [] {
                if !seen.contains(recommendedCoinId) {
                    // Get matching coin entity
                    if let coin = allCoins.first(where: { $0.id == recommendedCoinId }) {
                        recommendedCoins.append(coin)
                    }
                    
                    seen.insert(recommendedCoinId)
                }
            }
        }
        
        return recommendedCoins
    }
    
    // Gets the portfolio coin array in local map based on the specified id
    func getPortfolioCoins(portfolioId: String) -> [Coin] {
        guard let portfolio = portfolios[portfolioId] else { return [] }
        
        return portfolio.0
    }
    
    // Gets the number of coins for the specified portfolio id
    func getPortfolioNumOfCoins(portfolioId: String) -> Int {
        guard let portfolio = portfolios[portfolioId] else { return 0 }
        
        return portfolio.0.count
    }
    
    // Gets the managed coin core data array for the specified portfolio
    func getManagedCoins(portfolioId: String) -> [ManagedCoin] {
        return managedDataService.getManagedCoins(portfolioId: portfolioId)
    }
    
    // Portfolio functions:
    func getPortfolioName(portfolioId: String) -> String {
        return managedDataService.getPortfolioName(portfolioId: portfolioId)
    }
    
    func updatePortfolioName(portfolioId: String, updatedName: String) {
        return managedDataService.updatePortfolioName(portfolioId: portfolioId, updatedName: updatedName)
    }
    
    func createPortfolio(name: String) {
        let id = managedDataService.getNextPortfolioId()
        
        // Create portfolio
        managedDataService.createPortfolio(portfolioId: id, name: name)
        
        // Update existing selected id to active portfolio (must be done second due to order of execution)
        selectedPortfolioId = id
    }
    
    func deletePortfolio(portfolioId: String) {
        managedDataService.deletePortfolio(portfolioId: portfolioId)
    }
    
    // Returns the array of portfolios saved in core data
    func getPortfolios() -> [Portfolio] {
        return managedDataService.portfolios
    }
    
    // Returns the current portfolio's value
    func getPortfolioValue() -> Double {
        guard let portfolio = portfolios[selectedPortfolioId] else { return 0.0 }
        
        return portfolio.1
    }
    
    // Returns the current portfolio's profit or loss based on total value - cost basis
    func getPortfolioProfitLoss() -> Double {
        guard let portfolio = portfolios[selectedPortfolioId] else { return 0.0 }
        
        return portfolio.1 - portfolio.2
    }
    
    // Gets the list of summary items for the specified portfolio id
    func getSummaries(portfolioId: String) -> [any Summarizable] {
        guard let portfolio = portfolios[portfolioId] else { return [] }
        
        return portfolio.3
    }
    
    // Returns whether the portfolio contains any holdings-related data
    func containsHoldings(portfolioId: String) -> Bool {
        guard let portfolio = portfolios[portfolioId] else { return false }
        
        return portfolio.4
    }
    
    // Goal functions
    func createGoal(goalDescription: String, goalTarget: Double, goalDate: Date) {
        managedDataService.createGoal(portfolioId: selectedPortfolioId, goalDescription: goalDescription, goalTarget: goalTarget, goalDate: goalDate)
    }
    
    func updateGoal(goalId: String, goalDescription: String, goalTarget: Double, goalDate: Date) {
        managedDataService.updateGoal(portfolioId: selectedPortfolioId, goalId: goalId, goalDescription: goalDescription, goalTarget: goalTarget, goalDate: goalDate)
    }
    
    func deleteGoal(goalId: String) {
        managedDataService.deleteGoal(portfolioId: selectedPortfolioId, goalId: goalId)
    }
    
    // Returns the array of goals for the selected portfolio saved in core data
    func getGoals() -> [Goal] {
        return managedDataService.getGoals(portfolioId: selectedPortfolioId)
    }
}
