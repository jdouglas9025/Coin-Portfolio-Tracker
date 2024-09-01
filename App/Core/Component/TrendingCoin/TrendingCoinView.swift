import SwiftUI

struct TrendingCoinView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    let trendingCoin: TrendingCoin
    
    var body: some View {
        HStack(spacing: 0) {
            // Trending score rank
            Text(String(trendingCoin.trendingScore))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(themeViewModel.textColorTheme.primaryText)
                .frame(width: 25)
            
            // Coin logo (stored in file manager)
            ImageView(uri: trendingCoin.largeImage, id: trendingCoin.id, storedLocation: .fileManager)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .padding(.leading, 5)
            
            // Coin name, rank, symbol
            VStack {
                Text(trendingCoin.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeViewModel.textColorTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 5)
                
                HStack(spacing: 0) {
                    Text(String(trendingCoin.marketCapRank))
                        .font(.caption)
                        .foregroundStyle(themeViewModel.textColorTheme.secondaryText)
                        .padding(.leading, 5)
                    
                    Text(trendingCoin.symbol.uppercased())
                        .font(.caption)
                        .foregroundStyle(themeViewModel.textColorTheme.secondaryText)
                        // Slightly less padding to associate items
                        .padding(.leading, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Percent change
            let change = trendingCoin.priceChangePercentage24H ?? 0
            Text(change.asPercentage(isChange: true))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(change > 0 ? themeViewModel.textColorTheme.positive : change == 0 ? themeViewModel.textColorTheme.unchanged : themeViewModel.textColorTheme.negative)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
