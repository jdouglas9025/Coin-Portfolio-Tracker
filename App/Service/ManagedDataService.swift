import Foundation
import CoreData

// Retrieves and saves portfolio-related data to core data for the current user to enable portfolio tracking
class ManagedDataService {
    // Represents the active container for core data
    private let container: NSPersistentContainer
    // Name of container to lookup in core data
    private let containerName = "PortfolioContainer"
    // Name of entity types within core data
    private let coinEntityName = "ManagedCoin"
    private let goalEntityName = "Goal"
    private let portfolioEntityName = "Portfolio"
    // Context to perform operations
    private let context: NSManagedObjectContext
    
    @Published var portfolios: [Portfolio] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if (error != nil) {
                return
            }
        }
        
        context = container.viewContext
        
        // Load portfolios (and create default if first load) upon app launch
        self.loadPortfolios()
    }
        
    // Returns an array of managed coins for the specified portfolio (returns empty array if no match found)
    func getManagedCoins(portfolioId: String) -> [ManagedCoin] {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return [] }
        
        let managedCoins = portfolio.managedCoins?.allObjects as? [ManagedCoin]
        
        return managedCoins ?? []
    }
    
    // Updates (create, update) core data for a coin in the specified portfolio
    func updateCoin(portfolioId: String, coin: Coin, holdingAmount: Double, costBasis: Double, isWatched: Bool, selectedCoinNote: String) {
        // Get managedCoins array for this portfolio
        let managedCoins = getManagedCoins(portfolioId: portfolioId)
        
        // Get existing managed coin or create a new one if it doesn't exist
        if let managedCoin = managedCoins.first(where: { $0.id == coin.id }) {
            updateManagedCoin(managedCoin: managedCoin, holdingAmount: holdingAmount, costBasis: costBasis, isWatched: isWatched, selectedCoinNote: selectedCoinNote)
        } else {
            // No match found, so create a new coin in core data
            createManagedCoin(portfolioId: portfolioId, coin: coin, holdingAmount: holdingAmount, costBasis: costBasis, isWatched: isWatched)
        }
    }
    
    func deleteCoin(portfolioId: String, coin: Coin) {
        // Get managedCoins array for this portfolio
        let managedCoins = getManagedCoins(portfolioId: portfolioId)
        
        if let managedCoin = managedCoins.first(where: { $0.id == coin.id }) {
            deleteManagedCoin(managedCoin: managedCoin)
        }
    }
    
    // Returns the whether the corresponding managed coin (if available) is a watched coin
    func isWatchedCoin(portfolioId: String, coin: Coin) -> Bool {
        // Get managedCoins array for this portfolio
        let managedCoins = getManagedCoins(portfolioId: portfolioId)
        
        // Get managed coin from array
        guard let managedCoin = managedCoins.first(where: {$0.id == coin.id }) else { return false }
        
        // Return watchlist status
        return managedCoin.isWatched
    }
    
    // Returns the name of the portfolio for the selected id (or nil if no match found)
    func getPortfolioName(portfolioId: String) -> String {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return "" }
        
        return portfolio.portfolioName ?? ""
    }
    
    // Updates the name of the portfolio for the selected id
    func updatePortfolioName(portfolioId: String, updatedName: String) {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return }
        
        portfolio.portfolioName = updatedName
        
        save()
        loadPortfolios()
    }
    
    // Generates next available id for a new portfolio
    func getNextPortfolioId() -> String {
        // Converting empty string into int results in nil
        if let lastIdNum = Int(portfolios.max(by: { $0.portfolioId ?? "" < $1.portfolioId ?? "" })?.portfolioId ?? "") {
            // New id is +1 to last id
            return String(lastIdNum + 1)
        } else {
            // Return initial id of 0
            return String(0)
        }
    }
    
    func createPortfolio(portfolioId: String, name: String) {
        // Create new portfolio in this context
        let portfolio = Portfolio(context: container.viewContext)
        
        portfolio.portfolioId = portfolioId
        portfolio.portfolioName = name
    
        save()
        loadPortfolios()
    }

    // Deletes the specified portfolio
    func deletePortfolio(portfolioId: String) {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return }
        
        container.viewContext.delete(portfolio)
        
        save()
        loadPortfolios()
    }

    // Loads all portfolios from Core Data to the local array -- if a default portfolio does not exist, it is created
    private func loadPortfolios() {
        let request = NSFetchRequest<Portfolio>(entityName: portfolioEntityName)
        
        do {
            portfolios = try context.fetch(request)
            
            //Check if default portfolio doesn't exist yet (first time load)
            if portfolios.isEmpty {
                let id = getNextPortfolioId()
                
                // Create default, save, and refresh
                createPortfolio(portfolioId: id, name: "Default")
                save()
                
                // Update reference with newly created portfolio
                portfolios = try context.fetch(request)
            }
        } catch {}
    }
    
    private func createManagedCoin(portfolioId: String, coin: Coin, holdingAmount: Double, costBasis: Double, isWatched: Bool) {
        // Parent portfolio
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return }
        
        // Create a new coin entity and set its portfolio relationship attribute to parent (Core Data will perform necessary matching)
        let managedCoin = ManagedCoin(context: context)
        
        managedCoin.id = coin.id
        managedCoin.symbol = coin.symbol
        managedCoin.name = coin.name
        managedCoin.image = coin.image
        managedCoin.lastPrice = coin.currentPrice
        managedCoin.marketCapRank = Int64(coin.marketCapRank)
        
        // Set holdings/cost basis (may be default 0.0)
        managedCoin.holdingAmount = holdingAmount
        managedCoin.costBasis = costBasis
        
        managedCoin.isWatched = isWatched
        managedCoin.portfolio = portfolio
        
        save()
        loadPortfolios()
    }
    
    // Refreshes a managed coin with fresh data from server response (updates saved price, image, rank)
    func refreshManagedCoin(managedCoin: ManagedCoin, coin: Coin) {
        managedCoin.lastPrice = coin.currentPrice
        managedCoin.image = coin.image
        managedCoin.marketCapRank = Int64(coin.marketCapRank)
        
        save()
        loadPortfolios()
    }
    
    private func updateManagedCoin(managedCoin: ManagedCoin, holdingAmount: Double, costBasis: Double, isWatched: Bool, selectedCoinNote: String) {
        // Set holdings/cost basis (may be default 0.0)
        managedCoin.holdingAmount = holdingAmount
        managedCoin.costBasis = costBasis
    
        managedCoin.isWatched = isWatched
        managedCoin.note = selectedCoinNote
    
        save()
        loadPortfolios()
    }
    
    // Deletes the specified coin
    private func deleteManagedCoin(managedCoin: ManagedCoin) {
        container.viewContext.delete(managedCoin)
        
        save()
        loadPortfolios()
    }
    
    // Creates/updates a note associated with a particular managed coin
    func updateCoinNote(portfolioId: String, coin: Coin, note: String) {
        // Get managedCoins array for this portfolio
        let managedCoins = getManagedCoins(portfolioId: portfolioId)
        
        guard let managedCoin = managedCoins.first(where: {$0.id == coin.id }) else { return }
        
        managedCoin.note = note
        
        save()
        loadPortfolios()
    }
    
    // Gets the note associated with a managed coin if available
    func getCoinNote(portfolioId: String, coin: Coin) -> String? {
        // Get managedCoins array for this portfolio
        let managedCoins = getManagedCoins(portfolioId: portfolioId)
        
        guard let managedCoin = managedCoins.first(where: {$0.id == coin.id }) else { return nil }
        
        return managedCoin.note
    }
    
    // Creates a new goal for the specified portfolio
    func createGoal(portfolioId: String, goalDescription: String, goalTarget: Double, goalDate: Date) {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return }
        guard let goalId = getNextGoalId(portfolio: portfolio) else { return }
        
        let goal = Goal(context: container.viewContext)
        
        goal.goalId = goalId
        goal.goalDescription = goalDescription
        goal.goalTarget = goalTarget
        goal.goalDate = goalDate
        goal.portfolio = portfolio
        
        save()
        loadPortfolios()
    }
    
    // Updates the specified goal description, target, and/or date
    func updateGoal(portfolioId: String, goalId: String, goalDescription: String, goalTarget: Double, goalDate: Date) {
        let goals = getGoals(portfolioId: portfolioId)
        
        guard let goal = goals.first(where: { $0.goalId == goalId }) else { return }
        
        goal.goalDescription = goalDescription
        goal.goalTarget = goalTarget
        goal.goalDate = goalDate
        
        save()
        loadPortfolios()
    }
    
    // Deletes the specified goal
    func deleteGoal(portfolioId: String, goalId: String) {
        let goals = getGoals(portfolioId: portfolioId)
        
        guard let goal = goals.first(where: { $0.goalId == goalId }) else { return }
        
        container.viewContext.delete(goal)
        
        save()
        loadPortfolios()
    }
    
    // Returns a list of goals for the specified portfolio -- returns empty list if no match found
    func getGoals(portfolioId: String) -> [Goal] {
        guard let portfolio = portfolios.first(where: { $0.portfolioId == portfolioId }) else { return [] }
        
        let goals = portfolio.goals?.allObjects as? [Goal]
        
        return goals ?? []
    }
    
    private func getNextGoalId(portfolio: Portfolio) -> String? {
        // Get existing goals
        guard let goals = portfolio.goals?.allObjects as? [Goal] else { return nil }
        
        // Converting empty string into int results in nil
        if let lastIdNum = Int(goals.max(by: { $0.goalId ?? "" < $1.goalId ?? "" })?.goalId ?? "") {
            // New id is +1 to last id
            return String(lastIdNum + 1)
        } else {
            // Return initial id of 0
            return String(0)
        }
    }
    
    // Saves the current changes to core data
    private func save() {
        do {
            try context.save()
        } catch {}
    }
}
