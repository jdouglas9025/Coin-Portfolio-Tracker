import SwiftUI

struct RecommendedCoinView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let coin: Coin
    
    var body: some View {
        HStack(spacing: 0) {
            // Coin logo (stored in file manager)
            ImageView(uri: coin.image, id: coin.id, storedLocation: .fileManager)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding(.leading, 7.5)
            
            // Coin name, rank, symbol
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 5)
                
                HStack(spacing: 0) {
                    Text(String(coin.marketCapRank))
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .padding(.leading, 5)
                    
                    Text(coin.symbol.uppercased())
                        .font(.caption)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        // Slightly less padding to associate items
                        .padding(.leading, 4)
                }
                
                // Percent change
                if let change = coin.priceChangePercentage24H {
                    Text(change.asPercentage(isChange: true))
                        .font(.subheadline)
                        .foregroundStyle(change > 0 ? themeVM.textColorTheme.positive : change == 0 ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative)
                        .padding(.leading, 5)
                }
            }
        }
    }
}
