import SwiftUI

// Represents the view for an individual coin as a row
// Includes rank, picture, name/ticker, price, and price change
struct CoinView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let coin: Coin
    
    @Binding var portfolioMiddleColumn: PortfolioMiddleColumn
    
    let showRank: Bool
    // Outer padding (7.5 in most views, but 0 in edit portfolio view)
    let padding: Double
    
    var body: some View {
        // Align to top incase % change unavailable for price column
        HStack(alignment: .top, spacing: 0) {
            coinColumn
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Middle column
            if portfolioMiddleColumn == .holdings {
                holdingsColumn
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else if portfolioMiddleColumn == .costBasis {
                costBasisColumn
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else if portfolioMiddleColumn == .profitLoss {
                profitLossColumn
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            priceColumn
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .contentShape(Rectangle())
    }
}

extension CoinView {
    private var coinColumn: some View {
        HStack(spacing: 0) {
            if showRank {
                Text(String(coin.marketCapRank))
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    .frame(width: 25)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, padding)
            }
            
            // Coin logo (stored in file manager)
            ImageView(uri: coin.image, id: coin.id, storedLocation: .fileManager)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .padding(.leading, showRank ? 5 : padding)
            
            // Coin name/ticker
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
            }
            .padding(.leading, 5)
            .multilineTextAlignment(.leading)
        }
    }
    
    private var holdingsColumn: some View {
        VStack(alignment: .trailing){
            Text(coin.currentHoldingsValue.asCurrency())
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .fontWeight(.bold)
                
            Text((coin.currentHoldings ?? 0.00).asFormattedNumber())
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        }
        .font(.subheadline)
        .padding(.trailing, 5)
        .multilineTextAlignment(.leading)
    }
    
    private var costBasisColumn: some View {
        VStack(alignment: .trailing){
            Text((coin.costBasis ?? 0.00).asCurrency())
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .fontWeight(.bold)
                
            Text(coin.averageCostPerCoin.asCurrency())
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        }
        .font(.subheadline)
        .padding(.trailing, 5)
        .multilineTextAlignment(.leading)
    }
    
    private var profitLossColumn: some View {
        VStack(alignment: .trailing){
            Text(coin.profitLossAmount.asCurrency())
                .fontWeight(.bold)
                .foregroundStyle(coin.profitLossAmount > 0.0 ? themeVM.textColorTheme.positive : coin.profitLossAmount == 0.0 ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative)
                
            Text(coin.profitLossPercentage.asPercentage(isChange: true))
                .foregroundStyle(coin.profitLossPercentage > 0.0 ? themeVM.textColorTheme.positive : coin.profitLossPercentage == 0.0 ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative
                )
        }
        .font(.subheadline)
        .padding(.trailing, 5)
        .multilineTextAlignment(.leading)
    }
    
    private var priceColumn: some View {
        VStack(alignment: .trailing) {
            Text(coin.currentPrice.asCurrency())
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
            
            if let change = coin.priceChangePercentage24H {
                Text(change.asPercentage(isChange: true))
                    .foregroundStyle(change > 0.0 ? themeVM.textColorTheme.positive : change == 0.0 ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative)
            }
        }
        .font(.subheadline)
        .padding(.trailing, padding)
        .multilineTextAlignment(.trailing)
    }
}
