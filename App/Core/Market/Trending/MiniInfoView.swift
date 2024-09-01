import SwiftUI

// Intermediate view that verifies the coin is not nil and generates a mini info view for the coin
struct MiniInfoLoadingView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var trendingCoin: TrendingCoin?
    @Binding var trendingCoinSummary: [any Summarizable]
    
    // Matching coin in top coins data (if available)
    @Binding var topCoin: Coin?
    
    var body: some View {
        if let trendingCoin = trendingCoin {
            MiniInfoView(trendingCoin: trendingCoin, trendingCoinSummary: trendingCoinSummary, topCoin: topCoin)
                .preferredColorScheme(themeVM.backgroundColorTheme)
                .dynamicTypeSize(themeVM.textSizeTheme)
                .presentationDetents([.height(350.0)])
                .environmentObject(themeVM)
        }
    }
}

// Mini-info view for displaying data points for trending coin
struct MiniInfoView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @State var trendingCoin: TrendingCoin
    @State var trendingCoinSummary: [any Summarizable]
    @State var topCoin: Coin?
    @State private var showDetailLoadingView = false
    
    private let lineLimit = 3
    @State private var showFullDescription = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 10.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        // Description
                        let description = trendingCoin.description ?? ""
                        if !description.isEmpty {
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
                            .padding(.vertical)
                        }
                        
                        // Overview
                        VStack {
                            Text("Overview")
                                .font(.title)
                                .bold()
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            LazyVGrid(columns: columns, alignment: .leading, spacing: spacing, content: {
                                ForEach(trendingCoinSummary, id: \.id) { summary in
                                    SummaryView(summary: summary)
                                }
                            })
                        }
                        .padding(!description.isEmpty ? .bottom : .vertical)
                        
                        // Link to detail view (if available)
                        if topCoin != nil {
                            Button("More details", action: {
                                withAnimation(.easeInOut) {
                                    showDetailLoadingView.toggle()
                                }
                            })
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .opacity(1.0)
                            .padding(.bottom)
                        }
                    }
                    .sheet(isPresented: $showDetailLoadingView, content: {
                        DetailLoadingView(coin: $topCoin)
                    })
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal)
            }
            .navigationTitle(trendingCoin.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        // Coin logo (stored in file manager)
                        ImageView(uri: trendingCoin.largeImage, id: trendingCoin.id, storedLocation: .fileManager)
                            .frame(width: 35, height: 35, alignment: .leading)
                            .clipShape(Circle())
                        
                        Text(trendingCoin.symbol)
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    DismissButtonView()
                        .frame(width: 35, height: 35, alignment: .trailing)
                }
            }
        }
    }
}
