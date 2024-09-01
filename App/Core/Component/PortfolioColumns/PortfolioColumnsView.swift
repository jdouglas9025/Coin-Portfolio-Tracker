import SwiftUI

// Represents a reusable component for displaying the columns for a list of coins in portfolio-related views
struct PortfolioColumnsView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    // Determines whether to display sort menu (e.g., edit coin does not need menu)
    @State var showSortOption: Bool
    
    // Type of coins to sort (either portfolio or top coins)
    @Binding var sortOption: PrimaryViewModel.SortOption
    
    // Passed in by calling portfolio view to determine middle column shown
    @Binding var portfolioMiddleColumn: PortfolioMiddleColumn
    
    let padding: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            if showSortOption {
                // Menu is alternative to picker to allow style customization
                sortMenu
            }
            
            // Columns
            HStack {
                Text("Coin")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Middle
                HStack {
                    if portfolioMiddleColumn == .holdings {
                        Text("Holdings")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        middleColumnArrows
                    } else if portfolioMiddleColumn == .costBasis {
                        Text("Cost Basis")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        middleColumnArrows
                    } else if portfolioMiddleColumn == .profitLoss {
                        Text("Total P/L")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        middleColumnArrows
                    }
                }
                // Swipe layer
                .background(.clear)
                .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
                    // Switch on width for left/right swipe support
                    switch value.translation.width {
                        //Left swipe (backward)
                        case (...0):
                            if portfolioMiddleColumn == .holdings {
                                withAnimation(.easeInOut) {
                                    portfolioMiddleColumn = .costBasis
                                }
                            } else if portfolioMiddleColumn == .costBasis {
                                withAnimation(.easeInOut) {
                                    portfolioMiddleColumn = .profitLoss
                                }
                            }
                            
                        // Right swipe (forward)
                        case (0...):
                            if portfolioMiddleColumn == .costBasis {
                                withAnimation(.easeInOut) {
                                    portfolioMiddleColumn = .holdings
                                }
                            } else if portfolioMiddleColumn == .profitLoss {
                                withAnimation(.easeInOut) {
                                    portfolioMiddleColumn = .costBasis
                                }
                            }
                            
                        // Shouldn't execute
                        default:
                            withAnimation(.easeInOut) {
                                portfolioMiddleColumn = .holdings
                            }
                    }
                })
                
                Spacer()
                
                Text("Price")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption)
            .foregroundStyle(themeVM.textColorTheme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, padding)
    }
}

extension PortfolioColumnsView {
    private var middleColumnArrows: some View {
        HStack(spacing: 0) {
            Button {
                if portfolioMiddleColumn == .costBasis {
                    withAnimation(.easeInOut) {
                        portfolioMiddleColumn = .holdings
                    }
                } else if portfolioMiddleColumn == .profitLoss {
                    withAnimation(.easeInOut) {
                        portfolioMiddleColumn = .costBasis
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
            }
            .opacity((portfolioMiddleColumn == .holdings) ? 0.0 : 1.0)
        
            Button {
                if portfolioMiddleColumn == .holdings {
                    withAnimation(.easeInOut) {
                        portfolioMiddleColumn = .costBasis
                    }
                } else if portfolioMiddleColumn == .costBasis {
                    withAnimation(.easeInOut) {
                        portfolioMiddleColumn = .profitLoss
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
            }
            .opacity((portfolioMiddleColumn == .profitLoss) ? 0.0 : 1.0)
        }
    }
    
    private var sortMenu: some View {
        Menu {
            // Rank sub-menu
            Menu {
                Button {
                    withAnimation(.easeInOut) {
                        sortOption = .rank
                    }
                } label: {
                    HStack {
                        PrimaryViewModel.SortOption.rank.order
                        PrimaryViewModel.SortOption.rank.image
                    }
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                }
                
                Button {
                    withAnimation(.easeInOut) {
                        sortOption = .reverseRank
                    }
                } label: {
                    HStack {
                        PrimaryViewModel.SortOption.reverseRank.order
                        PrimaryViewModel.SortOption.reverseRank.image
                    }
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                }
            } label: {
                Text("Rank")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .padding(.leading, 5)
            }
            
            // Holdings sub-menu (only show if middle column isn't hidden)
            if portfolioMiddleColumn != .none {
                Menu {
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .holdings
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.holdings.order
                            PrimaryViewModel.SortOption.holdings.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .reverseHoldings
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.reverseHoldings.order
                            PrimaryViewModel.SortOption.reverseHoldings.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                } label: {
                    Text("Holdings")
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .padding(.leading, 5)
                }
                
                // Cost basis sub-menu
                Menu {
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .costBasis
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.costBasis.order
                            PrimaryViewModel.SortOption.costBasis.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .reverseCostBasis
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.reverseCostBasis.order
                            PrimaryViewModel.SortOption.reverseCostBasis.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                } label: {
                    Text("Cost Basis")
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .padding(.leading, 5)
                }
            }
            
            // Percent change sub-menu (only show if online)
            if homeVM.status != .offline {
                Menu {
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .percentChange
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.percentChange.order
                            PrimaryViewModel.SortOption.percentChange.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                    
                    Button {
                        withAnimation(.easeInOut) {
                            sortOption = .reversePercentChange
                        }
                    } label: {
                        HStack {
                            PrimaryViewModel.SortOption.reversePercentChange.order
                            PrimaryViewModel.SortOption.reversePercentChange.image
                        }
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                    }
                } label: {
                    Text("Percent Change")
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .padding(.leading, 5)
                }
            }
        } label: {
            HStack {
                sortOption.name
                sortOption.image
            }
            .font(.caption)
            .foregroundStyle(themeVM.textColorTheme.secondaryText)
            .padding(10)
            .background(BackgroundRoundedRectangleView())
        }
    }
}
