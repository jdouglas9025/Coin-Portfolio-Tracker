import SwiftUI

struct FutureView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var homeVM: PrimaryViewModel
    
    @State private var showCalculatorView = false
    @State private var selectedCalculator: Calculator?
    
    // Array of calculator items for looping
    private let calculators = [Calculator(type: .futureValue), Calculator(type: .historicalCagr), Calculator(type: .breakeven), Calculator(type: .capitalGains)]
    
    private let twoCol = [
        GridItem(.flexible(), spacing: 10.0, alignment: .top),
        GridItem(.flexible(), spacing: 10.0, alignment: .top)
    ]
    private let oneCol = [
        GridItem(.flexible(), spacing: 10.0, alignment: .top)
    ]
    private let spacing: CGFloat = 10.0
    
    var body: some View {
        ScrollView {
                let goals = homeVM.getGoals()
                
                if !goals.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Goals")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        LazyVGrid(columns: twoCol, alignment: .leading,
                                  spacing: spacing, content: {
                            ForEach(goals, id: \.self) { goal in
                                GoalView(goal: goal, showFullAmount: false)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .padding(10)
                                    .background(BackgroundRoundedRectangleView())
                            }
                        })
                        .padding(.horizontal, 5)
                    }
                    .padding([.horizontal, .bottom])
                }
        
                VStack(alignment: .leading) {
                    Text("Calculators")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    
                    LazyVGrid(columns: twoCol, alignment: .leading,
                              spacing: spacing, content: {
                        ForEach(calculators, id: \.title) { calculator in
                            CalculatorItemView(calculator: calculator)
                                // Align item within padding to top-left
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding()
                                .background(BackgroundRoundedRectangleView())
                                .onTapGesture {
                                    selectedCalculator = calculator
                                    withAnimation(.easeInOut) {
                                        showCalculatorView.toggle()
                                    }
                                }
                        }
                    })
                    .padding(.horizontal, 5)
                }
                .padding([.horizontal, .bottom])
                .sheet(isPresented: $showCalculatorView, content: {
                    CalculatorLoadingView(calculator: $selectedCalculator)
                })
            }
            .padding(.vertical)
            .scrollIndicators(.hidden)
    }
}

extension FutureView {
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
