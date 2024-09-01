import SwiftUI

// Sub-view inside portfolio selection view to edit portfolio name, coins, goals, etc.
struct EditPortfolioView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    
    @ObservedObject var portfolioInputValidationVM: PortfolioInputValidationViewModel
    
    @Binding var displayedView: PortfolioSelectionView.DisplayedView
    @Binding var selectedCoin: Coin?
    @Binding var selectedGoal: Goal?
    
    @State private var portfolioMiddleColumn: PortfolioMiddleColumn = .holdings
    
    let id: String
    let name: String
    let goals: [Goal]
    let coins: [Coin]
    let recommendedCoins: [Coin]
    
    private let spacing: CGFloat = 10.0
    private let columns = [
        GridItem(.flexible(), spacing: 10.0, alignment: .topLeading),
        GridItem(.flexible(), spacing: 10.0, alignment: .topLeading)
    ]
    
    var body: some View {
        VStack(spacing: 10.0) {
            VStack {
                Text("Edit Portfolio")
                    .font(.title)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack {
                    VStack {
                        HStack {
                            Text("Name: ")
                                .font(.headline)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            HStack {
                                TextField(name, text: $portfolioInputValidationVM.updatedName)
                                    .font(.headline)
                                    .foregroundStyle(portfolioInputValidationVM.updatedName.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                    .keyboardType(.default)
                                
                                // No clear text button since layout is confusing
                            }
                            .multilineTextAlignment(.leading)
                        }
                        
                        Text(portfolioInputValidationVM.updatedNamePrompt)
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.negative)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Divider()
                    }
                    .padding(.bottom)
                    
                    editButtons
                }
                .padding()
                .background(BackgroundRoundedRectangleView())
                .toolbar {
                    ToolbarItem(placement: .keyboard) {
                        keyboard
                    }
                }
            }
            .padding([.horizontal, .bottom])
            
            if !goals.isEmpty {
                VStack {
                    Text("Edit Goals")
                        .font(.title)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    LazyVGrid(columns: columns, alignment: .leading,
                              spacing: spacing, content: {
                        ForEach(goals, id: \.self) { goal in
                            GoalView(goal: goal, showFullAmount: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedGoal = goal
                                    
                                    withAnimation(.easeInOut) {
                                        displayedView = .editGoal
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(10)
                                .background(BackgroundRoundedRectangleView())
                        }
                    })
                    .padding(.horizontal, 5)
                }
                .padding([.horizontal, .bottom])
            }
            
            if !coins.isEmpty {
                VStack {
                    Text("Edit Coins")
                        .font(.title)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    VStack {
                        PortfolioColumnsView(showSortOption: true, sortOption: $primaryVM.portfolioSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 0)
                        coinsOverview
                    }
                    .frame(maxWidth: .infinity)
                
                }
                .padding([.horizontal, .bottom])
            }
            
            if !recommendedCoins.isEmpty {
                VStack {
                    Text("Similar Coins")
                        .font(.title)
                        .bold()
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(recommendedCoins) { coin in
                                RecommendedCoinView(coin: coin)
                                    .padding(.horizontal, 2.5)
                                    .scaleEffect(0.9)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedCoin = coin
                                        
                                        withAnimation(.easeInOut) {
                                            displayedView = .editCoin
                                        }
                                    }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .padding(.bottom)
    }
}

extension EditPortfolioView {
    private var editButtons: some View {
        HStack(alignment: .lastTextBaseline) {
            // Cancel (only show if change has been made)
            if !portfolioInputValidationVM.updatedName.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut) {
                        UIApplication.shared.hideKeyboard()
                        portfolioInputValidationVM.updatedName = ""
                    }
                }, label: {
                    CircleButtonView(iconName: "xmark", width: 40, height: 40)
                })
            }

            Spacer()
            
            VStack(spacing: 10) {
                // Delete (only show for non-default portfolio)
                if id != "0" {
                    Button(action: {
                        primaryVM.deletePortfolio(portfolioId: id)
                        
                        // Check if active portfolio was deleted
                        if primaryVM.selectedPortfolioId == id {
                            // Update active portfolio to default -- prevents having no active portfolio
                            primaryVM.selectedPortfolioId = "0"
                        }
                        
                        withAnimation(.easeIn) {
                            displayedView = .overview
                        }
                    }, label: {
                        CircleButtonView(iconName: "trash", width: 40, height: 40)
                    })
                }
                
                // Save (only show if valid)
                if portfolioInputValidationVM.allValidInputs {
                    Button(action: {
                        // Update portfolio name
                        primaryVM.updatePortfolioName(portfolioId: id, updatedName: portfolioInputValidationVM.updatedName)
                        
                        withAnimation(.easeInOut) {
                            UIApplication.shared.hideKeyboard()
                            portfolioInputValidationVM.updatedName = ""
                            displayedView = .overview
                        }
                    }, label: {
                        CircleButtonView(iconName: "checkmark", width: 40, height: 40)
                    })
                }
            }
        }
    }
    
    private var coinsOverview: some View {
        LazyVStack(spacing: 10) {
            ForEach(coins) { coin in
                CoinView(coin: coin, portfolioMiddleColumn: $portfolioMiddleColumn, showRank: false, padding: 0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCoin = coin
                        withAnimation(.easeInOut) {
                            displayedView = .editCoin
                        }
                    }
            }
        }
    }
    
    private var keyboard: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut) {
                    UIApplication.shared.hideKeyboard()
                }
            }, label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
            })
        }
    }
}
