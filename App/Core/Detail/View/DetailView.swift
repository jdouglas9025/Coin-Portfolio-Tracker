import SwiftUI

// Intermediate view that verifies the coin is not nil and generates a detail view for the coin
struct DetailLoadingView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @Binding var coin: Coin?
    
    var body: some View {
        // Verify that coin is not nil
        if let coin = coin {
            DetailView(homeVM: homeVM, themeVM: themeVM, coin: coin)
                .preferredColorScheme(themeVM.backgroundColorTheme)
                .dynamicTypeSize(themeVM.textSizeTheme)
        }
    }
}

// Represents a detailed view with various data points for a specific coin
struct DetailView: View {
    @ObservedObject private var homeVM: PrimaryViewModel
    @ObservedObject private var themeVM: ThemeViewModel
    
    @ObservedObject private var detailViewModel: DetailViewModel
    
    private let coin: Coin
    private let coinNote: String?
    
    // Used to determine at least one additional detail section available
    private var additionalDetailsAvailable: Bool {
        return
            (coin.description != nil && !(coin.description!.isEmpty)) ||
            detailViewModel.technicalSummaries.count > 0 ||
            detailViewModel.socialSummaries.count > 0
    }
    
    @State private var showAdditionalDetails = false
    
    @State private var showFullCoinNote = false
    @State private var showFullDescription = false
    
    // Loads a detail view for recommended coin that was clicked
    @State private var showDetailLoadingView = false
    @State private var selectedCoin: Coin?
    
    private let columns = [
        GridItem(.flexible(), alignment: .topLeading),
        GridItem(.flexible(), alignment: .topLeading),
        GridItem(.flexible(), alignment: .topLeading)
    ]
    private let spacing: CGFloat = 10.0
    
    private let lineLimit = 3
    
    private var periodValues: [Double] {
        switch homeVM.timeframeOption {
            case .sevenDays:
                detailViewModel.values7Days
            case .fiveDays:
                detailViewModel.values5Days
            case .threeDays:
                detailViewModel.values3Days
            case .oneDay:
                detailViewModel.values1Days
        }
    }
    
    private var periodEnd: Date {
        coin.sparklineLastUpdated?.asDate(dateType: .lastUpdated) ?? .now
    }
    
    private var overviewSummaries: [any Summarizable] {
        switch homeVM.timeframeOption {
            case .sevenDays:
                detailViewModel.overviewSummaries7Days
            case .fiveDays:
                detailViewModel.overviewSummaries5Days
            case .threeDays:
                detailViewModel.overviewSummaries3Days
            case .oneDay:
                detailViewModel.overviewSummaries1Days
        }
    }
    
    init(homeVM: PrimaryViewModel, themeVM: ThemeViewModel, coin: Coin) {
        self.homeVM = homeVM
        self.themeVM = themeVM
        self.coin = coin
        
        self.detailViewModel = DetailViewModel(coin: coin)
        
        coinNote = homeVM.getCoinNote(coin: coin)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // Current price and percent change
                        VStack {
                            Text("Current Overview")
                                .font(.title)
                                .bold()
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            LazyVGrid(
                                columns: columns,
                                alignment: .leading,
                                spacing: spacing,
                                content: {
                                    SummaryView(summary: CurrencySummary(title: "Price", value: coin.currentPrice, isChange: false))
                                    SummaryView(summary: CurrencySummary(title: "Change", value: coin.priceChange24H ?? 0.0, isChange: true))
                                    SummaryView(summary: PercentSummary(title: "% Change", value: coin.priceChangePercentage24H ?? 0.0, isChange: true))
                                })
                        }
                        .padding(.vertical)
                        
                        
                        if homeVM.status != .offline {
                            // Chart
                            VStack {
                                Text(homeVM.timeframeOption.rawValue + " Price Change")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Chart last update time
                                Text("Last updated " + periodEnd.formatted(GeneralUtility.chartDateFormatter))
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                
                                Divider()
                                
                                CustomAreaChartView(themeVM: themeVM, periodValues: periodValues, periodEnd: periodEnd)
                                    .frame(height: 300)
                                    .padding(.top, 75)
                                    .padding(.trailing, 5)
                            }
                            .padding(.bottom)
                            
                            // Overview
                            VStack {
                                Text("Period Overview")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Period details last update time (based on chart)
                                Text("Last updated " + periodEnd.formatted(GeneralUtility.chartDateFormatter))
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        ForEach(overviewSummaries, id: \.id) { summary in
                                            SummaryView(summary: summary)
                                        }
                                    })
                            }
                            .padding(.bottom)
                        } else {
                            CustomAlertView(customAlert: .serverOffline)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                        }
                      
                        // Holdings
                        if let currentHoldings = coin.currentHoldings, currentHoldings > 0.0 {
                            VStack {
                                Text("Holdings")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        let value = CurrencySummary(title: "Value", value: coin.currentHoldingsValue, isChange: false)
                                        let amount = DoubleSummary(title: "Amount", value: currentHoldings, isChange: false)
                                        let costBasis = CurrencySummary(title: "Cost Basis", value: coin.costBasis ?? 0.0, isChange: false)
                                        let profitLoss = CurrencySummary(title: "Profit/Loss", value: coin.profitLossAmount, isChange: true)
                                        let profitLossPercentage = PercentSummary(title: "Profit/Loss %", value: coin.profitLossPercentage, isChange: true)
                                        
                                        SummaryView(summary: value)
                                        SummaryView(summary: amount)
                                        SummaryView(summary: costBasis)
                                        SummaryView(summary: profitLoss)
                                        SummaryView(summary: profitLossPercentage)
                                    })
                            }
                            .padding(.bottom)
                        }
                        
                        // Notes
                        if let coinNote {
                            VStack {
                                Text("Notes")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                HStack {
                                    Text(coinNote)
                                        .font(.subheadline)
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                        .lineLimit(showFullCoinNote ? nil : lineLimit)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showFullCoinNote.toggle()
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        // Ranking
                        if homeVM.status != .offline {
                            VStack {
                                Text("Ranking")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        ForEach(detailViewModel.additionalSummaries, id: \.id) { summary in
                                            SummaryView(summary: summary)
                                        }
                                    })
                            }
                            .padding(.bottom)
                        }
                        
                        // Similar coins
                        if let recommendedCoins = coin.recommendedCoins, !recommendedCoins.isEmpty {
                            VStack {
                                Text("Similar Coins")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                ScrollView(.horizontal) {
                                    // Use stack over grid since only one row
                                    LazyHStack {
                                        ForEach(recommendedCoins, id: \.self) { coinId in
                                            // Get matching coin based on id
                                            let coin = homeVM.allCoins.first(where: { $0.id == coinId })
                                            if let coin {
                                                RecommendedCoinView(coin: coin)
                                                    .padding(.horizontal, 2.5)
                                                    // Scale size down
                                                    .scaleEffect(0.9)
                                                    .onTapGesture {
                                                        selectedCoin = coin
                                                        withAnimation(.easeInOut) {
                                                            showDetailLoadingView.toggle()
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                                .scrollIndicators(.hidden)
                            }
                            .padding(.bottom)
                            .sheet(isPresented: $showDetailLoadingView, content: {
                                DetailLoadingView(coin: $selectedCoin)
                            })
                        }
                        
                        if showAdditionalDetails {
                            // Description
                            if let description = coin.description, !description.isEmpty {
                                VStack {
                                    Text("Description")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(showFullDescription ? nil : lineLimit)
                                            .multilineTextAlignment(.leading)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            showFullDescription.toggle()
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                            
                            // Historical overview
                            VStack {
                                Text("Historical Overview")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                LazyVGrid(
                                    columns: columns,
                                    alignment: .leading,
                                    spacing: spacing,
                                    content: {
                                        ForEach(detailViewModel.historicalSummaries, id: \.id) { summary in
                                            SummaryView(summary: summary)
                                        }
                                    })
                            }
                            .padding(.bottom)
                            
                            // Technical Details
                            if detailViewModel.technicalSummaries.count > 0 {
                                VStack {
                                    Text("Network Details")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                    
                                    LazyVGrid(
                                        columns: columns,
                                        alignment: .leading,
                                        spacing: spacing,
                                        content: {
                                            ForEach(detailViewModel.technicalSummaries, id: \.id) { summary in
                                                SummaryView(summary: summary)
                                            }
                                        })
                                }
                                .padding(.bottom)
                            }
                            
                            // Social Details
                            if detailViewModel.socialSummaries.count > 0 {
                                VStack {
                                    Text("Social Details")
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                    
                                    LazyVGrid(
                                        columns: [GridItem(.flexible(), alignment: .topLeading)],
                                        alignment: .leading,
                                        spacing: spacing,
                                        content: {
                                            ForEach(detailViewModel.socialSummaries, id: \.id) { summary in
                                                SummaryView(summary: summary)
                                                    .onTapGesture {
                                                        if summary is UrlSummary {
                                                            // Type cast and set URL
                                                            if let urlSummary = summary as? UrlSummary {
                                                                if let url = urlSummary.url {
                                                                    // Use UIApplication.shared.open() to open URLs in new window
                                                                    UIApplication.shared.open(url)
                                                                }
                                                            }
                                                        }
                                                    }
                                            }
                                        })
                                }
                            }
                        }
                        
                        // Place expand button below content so button is moved to bottom
                        if additionalDetailsAvailable {
                            ExpandButtonView(showView: $showAdditionalDetails)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(5)
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
                .scrollIndicators(.hidden)
            }
            
            .navigationTitle(coin.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        // Coin logo (stored in file manager)
                        ImageView(uri: coin.image, id: coin.id, storedLocation: .fileManager)
                            .frame(width: 35, height: 35, alignment: .leading)
                            .clipShape(Circle())
                        
                        Text(coin.symbol.uppercased())
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        TimeframeMenuView()
                            .opacity(homeVM.status == .offline ? 0.70 : 1.0)
                            .disabled(homeVM.status == .offline ? true : false)
                     
                        DismissButtonView()
                            .frame(width: 35, height: 35, alignment: .trailing)
                    }
                }
            }
        }
    }
}
