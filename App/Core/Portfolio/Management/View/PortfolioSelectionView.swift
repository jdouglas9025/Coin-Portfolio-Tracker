import SwiftUI

// Represents the portfolio management view where users can select/edit/delete portfolios and items within a portfolio
struct PortfolioSelectionView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Tracks which view to display in this container
    enum DisplayedView {
        case overview, addPortfolio, editPortfolio, addCoin, addGoal, editCoin, editGoal
    }
    
    // Default value of overview view
    @State private var displayedView: DisplayedView = .overview
    
    // Initialize with default portfolio -- does not impact active portfolio
    @State private var selectedPortfolioId = "0"
    // Original portfolio name -- not updated
    @State private var selectedPortfolioName = "Default"
    // Selected coin in current portfolio
    @State private var selectedCoin: Coin?
    
    private var portfolioCoins: [Coin] {
        return homeVM.getPortfolioCoins(portfolioId: selectedPortfolioId)
    }
    private var portfolioRecommendedCoins: [Coin] {
        return homeVM.getRecommendedCoins()
    }
    private var portfolioGoals: [Goal] {
        return homeVM.getGoals()
    }
    
    @State private var selectedGoal: Goal?
    
    private let spacing: CGFloat = 10.0
    private let columns = [
        GridItem(.flexible(), spacing: 10.0, alignment: .topLeading),
        GridItem(.flexible(), spacing: 10.0, alignment: .topLeading)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    switch displayedView {
                        case .overview:
                            portfolioOverview
                        case .addPortfolio:
                            AddPortfolioView(portfolioInputValidationVM: PortfolioInputValidationViewModel(name: ""), displayedView: $displayedView)
                        case .editPortfolio:
                            EditPortfolioView(portfolioInputValidationVM: PortfolioInputValidationViewModel(name: selectedPortfolioName), displayedView: $displayedView, selectedCoin: $selectedCoin, selectedGoal: $selectedGoal, id: selectedPortfolioId, name: selectedPortfolioName, goals: portfolioGoals, coins: portfolioCoins, recommendedCoins: portfolioRecommendedCoins)
                        case .addCoin:
                            AddCoinView(displayedView: $displayedView)
                                .onDisappear {
                                    // Reset search bar text and sort
                                    homeVM.topCoinsSearchBarText = ""
                                    homeVM.topCoinsSortOption = .rank
                                }
                        case .addGoal:
                            AddGoalView(displayedView: $displayedView)
                        case .editGoal:
                            if let selectedGoal {
                                EditGoalView(goal: selectedGoal, displayedView: $displayedView)
                            }
                        case .editCoin:
                            if let selectedCoin {
                                EditCoinView(primaryVM: homeVM, displayedView: $displayedView, selectedPortfolioId: selectedPortfolioId, selectedCoin: selectedCoin)
                            }
                    }
                }
                // Only apply top padding -- cannot do bottom since causes issue with keyboard
                .padding(.top)
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
                
                if displayedView == .editPortfolio {
                    // Add coin/goal button
                    floatingMenuButton
                } else if displayedView == .overview {
                    // Add portfolio button (only show if less than 10 portfolios)
                    if homeVM.getPortfolios().count < 10 {
                        HoveringPlusButtonView()
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    displayedView = .addPortfolio
                                }
                            }
                    }
                }
            }
            
            // Stack props:
            .navigationTitle("Manage Portfolios")
            .toolbar {
                // Back button (only certain views)
                ToolbarItem(placement: .topBarLeading) {
                    BackButtonView()
                        .opacity((displayedView == .overview) ? 0.0 : 1.0)
                        .onTapGesture {
                            switch displayedView {
                                // Return to edit portfolio rather than main view
                                case .editCoin, .addCoin, .editGoal, .addGoal:
                                    withAnimation(.easeInOut) {
                                        displayedView = .editPortfolio
                                    }
    
                                default:
                                    withAnimation(.easeInOut) {
                                        displayedView = .overview
                                    }
                            }
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButtonView()
                }
            }
        }
    }
}


extension PortfolioSelectionView {
    private var portfolioOverview: some View {
        VStack {
            Text("Overview")
                .font(.title)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: spacing, content: {
                // Iterate over all portfolios
                ForEach(homeVM.getPortfolios()) { portfolio in
                    let id = portfolio.portfolioId ?? ""
                    let name = portfolio.portfolioName ?? ""
                    let numOfCoins = homeVM.getPortfolioNumOfCoins(portfolioId: id)
                    let summaries = homeVM.getSummaries(portfolioId: id)
                    // Whether current portfolio is user's active one
                    let isActive = (homeVM.selectedPortfolioId == id)
                    
                    PortfolioItemView(displayedView: $displayedView, selectedPortfolioId: $selectedPortfolioId, selectedPortfolioName: $selectedPortfolioName, id: id, name: name, numOfCoins: numOfCoins, summaries: summaries, isActive: isActive)
                        .onTapGesture {
                            // Set portfolio as active view and persist to app storage
                            homeVM.selectedPortfolioId = id
                            
                            withAnimation(.easeInOut) {
                                dismiss()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                        .background(BackgroundRoundedRectangleView())
                }
            })
            // Push off slightly from edges to prevent clipping
            .padding(.horizontal, 5)
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
    
    private var floatingMenuButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Wrap menu inside hovering button layout -- swap circle item for menu and label
                Menu(content: {
                    Button {
                        withAnimation(.easeInOut) {
                            displayedView = .addCoin
                        }
                    } label: {
                        Text("Add Coin")
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            displayedView = .addGoal
                        }
                    } label: {
                        Text("Add Goal")
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                }, label: {
                    CircleButtonView(iconName: "plus", width: 60, height: 60)
                        .frame(alignment: .trailing)
                        .padding([.bottom, .trailing])
                })
            }
        }
    }
}
