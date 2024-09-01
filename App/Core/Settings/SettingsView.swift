import SwiftUI

// Displays customization, about, and attribution details
struct SettingsView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    private let coinGeckoUrl = URL(string: "https://www.coingecko.com")
    private let googleNewsUrl = URL(string: "https://news.google.com")
    
    var body: some View {
        ZStack {
            themeVM.textColorTheme.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Text("Customize")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    ThemeSelectorView()
                }
                
                VStack {
                    Text("About")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                 
                    VStack {
                        about
                            .contentShape(Rectangle())
                    }
                }
                
                VStack {
                    Text("Attributions")
                        .font(.title)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                 
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        // CoinGecko
                        VStack {
                            Image("CoinGeckoLogo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        if let coinGeckoUrl = coinGeckoUrl {
                                            // Use UIApplication.shared.open() to open URLs in new window
                                            UIApplication.shared.open(coinGeckoUrl)
                                        }
                                    }
                                }
                            
                            Text("Prices, logos, and other coin-related data retrieved from CoinGecko's API. Thank you, CoinGecko!")
                                .font(.caption)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        }
                        .padding(.bottom)
                            
                        // Google News
                        VStack {
                            Image("GoogleNewsLogo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        if let googleNewsUrl {
                                            UIApplication.shared.open(googleNewsUrl)
                                        }
                                    }
                                }
                            Text("News feed retrieved from Google News. Thank you, Google!")
                                .font(.caption)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        }
                        .padding(.bottom)
                    }
                }
            }
            .padding()
            .scrollIndicators(.hidden)
        }
    }
}

extension SettingsView {
    private var about: some View {
        VStack(alignment: .leading, spacing: 20) {
            (Text("Thank you for using ").foregroundStyle(themeVM.textColorTheme.secondaryText) + Text("Coin Portfolio Tracker!").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold))
                
                Text("Keep in mind that data in this app may be delayed. To see when the app's data was last refreshed, click the information icon in the ").foregroundStyle(themeVM.textColorTheme.secondaryText) + Text("Top Coins").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" tab.").foregroundStyle(themeVM.textColorTheme.secondaryText)
                
                Text("Additionally, while I strive to ensure the accuracy of all calculators, inaccurate results may occur. Before making any financial decision, please review information against other sources and consult with a licensed professional.").foregroundStyle(themeVM.textColorTheme.secondaryText)
                
                Text("In the future, I intend to add additional calculators and more advanced coin tracking. All the best,").foregroundStyle(themeVM.textColorTheme.secondaryText) + Text("\nJacob Douglas").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold)
        }
        .font(.subheadline)
        .padding(.bottom)
    }
}
