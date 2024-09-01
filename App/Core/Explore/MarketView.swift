import SwiftUI

// Market view tab for displaying trending coins + news data
struct MarketView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    // Index of first trending coin to display for this page (~4x per page)
    @State private var startIndex = 0
    
    // Range to iterate through for all trending coins
    private var range: Range<Int> {
        var endIndex = startIndex + 4
        
        // Check if last page (or empty array)
        if endIndex >= homeVM.trendingCoins.count {
            endIndex = homeVM.trendingCoins.count
        }
        
        return startIndex..<endIndex
    }
    
    // Selected coin, top coin equivalent, summaries to display in mini-info view
    @State private var selectedCoin: TrendingCoin?
    @State private var selectedCoinSummaries: [any Summarizable] = []
    @State private var selectedTopCoin: Coin?
    @State private var showMiniInfoView = false
    
    // States for showing articles with in-app browser
    @State private var showLoadingBrowserView = false
    @State private var selectedArticle: News?
    
    private let twoCol = [
        GridItem(.flexible(), spacing: 10.0, alignment: .top),
        GridItem(.flexible(), spacing: 10.0, alignment: .top)
    ]
    private let oneCol = [
        GridItem(.flexible(), spacing: 10.0, alignment: .top)
    ]
    private let spacing: CGFloat = 10.0
    
    var body: some View {
        // Wrap in scroll view
        ScrollView {
            if !networkMonitor.isOnline {
                CustomAlertView(customAlert: .deviceOffline)
                    .padding(10)
                    .frame(maxWidth: .infinity)
            } else if homeVM.status == .offline {
                CustomAlertView(customAlert: .serverOffline)
                    .padding(10)
                    .frame(maxWidth: .infinity)
            } else {
                if !homeVM.trendingCoins.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Trending")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        marketColumnTitles
                        
                        HStack {
                            LazyVGrid(columns: oneCol, spacing: spacing, content: {
                                ForEach(range, id: \.self) { i in
                                    TrendingCoinView(trendingCoin: homeVM.trendingCoins[i])
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            // Load mini-info view for this coin
                                            selectedCoin = homeVM.trendingCoins[i]
                                            selectedCoinSummaries = homeVM.trendingCoinSummaries[i]
                                            // Find top coin equivalent if available
                                            selectedTopCoin = homeVM.allCoins.first(where: {
                                                $0.id == homeVM.trendingCoins[i].id
                                            })
                                            
                                            withAnimation(.easeInOut) {
                                                showMiniInfoView.toggle()
                                            }
                                        }
                                }
                            })
                            // Set max height to expand all items to max height in group
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            
                            // Navigation buttons
                            HStack(spacing: 0) {
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        startIndex -= 4
                                    }
                                }, label: {
                                    Image(systemName: "chevron.left")
                                })
                                .opacity((startIndex == 0) ? 0.0 : 1.0)
                                
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        startIndex += 4
                                    }
                                }, label: {
                                    Image(systemName: "chevron.right")
                                })
                                .opacity((startIndex + 4 >= homeVM.trendingCoins.count) ? 0.0 : 1.0)
                            }
                            .font(.headline)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                        }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
                            switch value.translation.width {
                                case (...0):
                                    if startIndex + 4 < homeVM.trendingCoins.count {
                                        withAnimation(.easeInOut) {
                                            startIndex += 4
                                        }
                                    }
                                    
                                case (0...):
                                    if startIndex != 0 {
                                        withAnimation(.easeInOut) {
                                            startIndex -= 4
                                        }
                                    }
                                    
                                default:
                                    break
                            }
                        })
                    }
                    .padding([.horizontal, .bottom])
                    .sheet(isPresented: $showMiniInfoView, content: {
                        MiniInfoLoadingView(trendingCoin: $selectedCoin, trendingCoinSummary: $selectedCoinSummaries, topCoin: $selectedTopCoin)
                    })
                }
            
                if !homeVM.newsFeed.isEmpty || !homeVM.newsSearchBarText.isEmpty {
                    VStack {
                        VStack(alignment: .leading) {
                            Text("News")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            SearchBarView(searchBarText: $homeVM.newsSearchBarText, padding: 5)
                            
                            if homeVM.newsFeed.isEmpty {
                                // No matches for filter
                                CustomAlertView(customAlert: .noMatches)
                                    .padding(5)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Menu {
                                    ForEach(PrimaryViewModel.NewsSortOption.allCases, id: \.rawValue) { newsSortOption in
                                        Button {
                                            homeVM.newsSortOption = newsSortOption
                                        } label: {
                                            HStack {
                                                newsSortOption.text
                                                newsSortOption.image
                                            }
                                            .font(.headline)
                                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                                            .dynamicTypeSize(themeVM.textSizeTheme)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        homeVM.newsSortOption.text
                                        homeVM.newsSortOption.image
                                    }
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    .padding(10)
                                    .background(BackgroundRoundedRectangleView())
                                    .padding(.horizontal, 5)
                                }
                                
                                LazyVGrid(columns: twoCol, spacing: spacing, content: {
                                    ForEach(homeVM.newsFeed) { article in
                                        NewsView(news: article)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                withAnimation(.easeInOut) {
                                                    // Load article
                                                    selectedArticle = article
                                                    showLoadingBrowserView.toggle()
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                            .padding(10)
                                            .background(BackgroundRoundedRectangleView())
                                            .multilineTextAlignment(.leading)
                                    }
                                })
                                .padding(.horizontal, 5)
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                    .sheet(isPresented: $showLoadingBrowserView, content: {
                        BrowserLoadingView(article: $selectedArticle)
                    })
                }
            }
        }
        .padding(.vertical)
        .scrollIndicators(.hidden)
        .refreshable {
            homeVM.reloadData()
        }
    }
}

extension MarketView {
    private var marketColumnTitles: some View {
        HStack {
            HStack {
                Text("Score")
                
                Text("Name")
                    .padding(.leading, 30)
                
                Spacer()
                
                Text("% Change")
                    .padding(.trailing, 30)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption)
        .foregroundStyle(themeVM.textColorTheme.secondaryText)
    }
}
