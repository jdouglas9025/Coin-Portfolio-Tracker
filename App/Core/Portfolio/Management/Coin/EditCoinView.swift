import SwiftUI

// Represents the view for editing a coin's holdings/watchlist status for the current portfolio
// Used in add coin, management, detail views
struct EditCoinView: View {
    @ObservedObject private var primaryVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @ObservedObject private var coinInputValidationVM: CoinInputValidationViewModel
    
    // Returns to parent view when cancel/save button clicked
    @Binding private var displayedView: PortfolioSelectionView.DisplayedView
    
    @State private var portfolioMiddleColumn: PortfolioMiddleColumn = .none
    
    @State private var selectedCoin: Coin
    @State private var isWatchedCoin = false
    @State private var isManagedCoin = false
    
    @FocusState private var focusedField: FocusedField?
    
    init(primaryVM: PrimaryViewModel, displayedView: Binding<PortfolioSelectionView.DisplayedView>, selectedPortfolioId: String, selectedCoin: Coin) {
        self.primaryVM = primaryVM
        _displayedView = displayedView
        
        self.selectedCoin = selectedCoin
        
        // Get watchlist status for coin if available and update VM values
        if let managedCoin = primaryVM.getManagedCoins(portfolioId: selectedPortfolioId).first(where: {$0.id == selectedCoin.id}) {
            isManagedCoin = true
            isWatchedCoin = managedCoin.isWatched
            
            // Check if no holdings/cost basis data
            if managedCoin.holdingAmount == 0.0 || managedCoin.costBasis == 0.0 {
                // Construct with nil to prevent error messages
                self.coinInputValidationVM = CoinInputValidationViewModel(holdings: nil, costBasis: nil, notes: managedCoin.note ?? "")
            } else {
                // Construct VM with values
                self.coinInputValidationVM = CoinInputValidationViewModel(holdings: managedCoin.holdingAmount, costBasis: Int(managedCoin.costBasis), notes: managedCoin.note ?? "")
            }
        } else {
            self.coinInputValidationVM = CoinInputValidationViewModel(holdings: nil, costBasis: nil, notes: "")
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                Text("Edit Coin")
                    .font(.title)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // Coin overview
                PortfolioColumnsView(showSortOption: false, sortOption: $primaryVM.portfolioSortOption, portfolioMiddleColumn: $portfolioMiddleColumn, padding: 0)
                CoinView(coin: selectedCoin, portfolioMiddleColumn: $portfolioMiddleColumn, showRank: false, padding: 7.5)
            }
            .padding(.horizontal)
            
            // Inputs
            VStack {
                VStack {
                    HStack {
                        Text("Watchlisted: ")
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            // Remove from watchlist
                            Button(action: {
                                isWatchedCoin = false
                            }, label: {
                                Image(systemName: "xmark")
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .padding(2.5)
                                    .frame(width: 50, height: 20)
                                    .background(
                                        Capsule()
                                            .foregroundStyle(themeVM.textColorTheme.negative.opacity(0.60))
                                            // Only show capsule if not in watchlist
                                            .opacity(!isWatchedCoin ? 1.0 : 0.0)
                                    )
                            })
                            
                            // Add to watchlist
                            Button(action: {
                                isWatchedCoin = true
                            }, label: {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .padding(2.5)
                                    .frame(width: 50, height: 20)
                                    .background(
                                        Capsule()
                                            .foregroundStyle(themeVM.textColorTheme.positive.opacity(0.60))
                                            // Only show capsule if in watchlist
                                            .opacity(isWatchedCoin ? 1.0 : 0.0)
                                    )
                            })
                        }
                        .padding(2.5)
                        .background(
                            Capsule()
                                .fill(themeVM.textColorTheme.secondaryText.opacity(0.60))
                        )
                    }
                    
                    Divider()
                }
                .padding(.bottom)
                
                VStack {
                    HStack {
                        Text("Holdings: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        TextField((coinInputValidationVM.holdings ?? 0.0).asFormattedNumber(), value: $coinInputValidationVM.holdings, format: .number)
                            .focused($focusedField, equals: .first)
                            .foregroundStyle(coinInputValidationVM.holdings == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)

                    // Show updated holdings if available otherwise show saved values
                    if let holdings = coinInputValidationVM.holdings, holdings > 0.0 {
                        let currentValue = holdings * selectedCoin.currentPrice
                        
                        HStack {
                            Text("Current Value: ")
                            Spacer()
                            Text(currentValue.asCurrency())
                        }
                        .font(.subheadline)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    }
                    
                    Text(coinInputValidationVM.holdingsPrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                }
                .padding(.bottom)
                
                VStack {
                    HStack {
                        Text("Cost Basis: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        TextField(Double(coinInputValidationVM.costBasis ?? 0).asCurrency(), value: $coinInputValidationVM.costBasis, format: GeneralUtility.intCurrencyFormatter)
                            .focused($focusedField, equals: .second)
                            .foregroundStyle(coinInputValidationVM.costBasis == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    // Show updated average cost if available otherwise show saved values
                    if let holdings = coinInputValidationVM.holdings, holdings > 0.0, let costBasis = coinInputValidationVM.costBasis, costBasis > 0 {
                        let averageCost = Double(costBasis) / holdings
                        
                        HStack {
                            Text("Average Cost per Coin: ")
                            Spacer()
                            Text(averageCost.asCurrency())
                        }
                        .font(.subheadline)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    }
                    
                    Text(coinInputValidationVM.costBasisPrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                }
                .padding(.bottom)
                
                VStack {
                    VStack(alignment: .leading) {
                        Text("Notes: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        TextField(coinInputValidationVM.notes, text: $coinInputValidationVM.notes, axis: .vertical)
                            .focused($focusedField, equals: .third)
                            .foregroundStyle(coinInputValidationVM.notes.isEmpty ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                            .keyboardType(.default)
                            // Min lines of 3 with max of 5 before scrolling
                            .lineLimit(3...5)
                            .multilineTextAlignment(.leading)
                            .padding(10)
                            .background(BackgroundRoundedRectangleView())
                    }
                    .font(.headline)
                    
                    Text(coinInputValidationVM.notesPrompt)
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()
                }
                .padding(.bottom)
            
                if coinInputValidationVM.allValidInputs {
                    actionButtons
                }
            }
            .padding()
            .background(BackgroundRoundedRectangleView())
            .padding()
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    InputKeyboard(focusedField: $focusedField, numOfFields: 3)
                }
            }
        }
    }
}

extension EditCoinView {
    private var actionButtons: some View {
        HStack(alignment: .lastTextBaseline) {
            // Cancel
            Button(action: {
                withAnimation(.easeInOut) {
                    displayedView = .editPortfolio
                }
            }, label: {
                CircleButtonView(iconName: "xmark", width: 40, height: 40)
            })

            Spacer()
            
            VStack(spacing: 10) {
                // Delete (only show if some data stored on coin)
                if isManagedCoin {
                    Button(action: {
                        deleteCoin()
                        
                        withAnimation(.easeInOut) {
                            focusedField = nil
                            displayedView = .editPortfolio
                        }
                    }, label: {
                        CircleButtonView(iconName: "trash", width: 40, height: 40)
                    })
                }
                
                // Save (only show if some data to save)
                let hasData = (coinInputValidationVM.holdings != nil && coinInputValidationVM.costBasis != nil) || !coinInputValidationVM.notes.isEmpty || isWatchedCoin
                
                if hasData {
                    Button(action: {
                        updateCoin()
                        
                        withAnimation(.easeInOut) {
                            focusedField = nil
                            displayedView = .editPortfolio
                        }
                    }, label: {
                        CircleButtonView(iconName: "checkmark", width: 40, height: 40)
                    })
                }
            }
        }
    }
    
    // Updates the coin in Core Data
    private func updateCoin() {
        primaryVM.updateCoin(coin: selectedCoin, holdingAmount: coinInputValidationVM.holdings ?? 0.0, costBasis: Double(coinInputValidationVM.costBasis ?? 0), isWatched: isWatchedCoin, selectedCoinNote: coinInputValidationVM.notes)
    }
    
    // Deletes the coin in Core Data
    private func deleteCoin() {
        primaryVM.deleteCoin(coin: selectedCoin)
    }
}
