import SwiftUI
import Charts

// Allows user to calculate historical CAGR of portfolio
struct HistoricalCagrView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var historicalCagrVM: HistoricalCagrViewModel
    
    // Used to pull information about this item
    let calculator: Calculator
    
    @FocusState private var focusedField: FocusedField?
  
    var body: some View {
        NavigationStack {
            ZStack {
                themeVM.textColorTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        VStack {
                            Text(calculator.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.subheadline)
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .padding(.bottom)
                        
                        VStack {
                            Text("Instructions")
                                .font(.title)
                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack {
                                (Text("1.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the initial value of your portfolio (i.e., how much you invested).").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                (Text("2.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the final value of your portfolio.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical)
                                
                                (Text("3.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the number of years you held your portfolio.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.subheadline)
                            .padding(.bottom)
                        }
                    }
                    
                    VStack {
                        Text("Inputs")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        VStack {
                            // Initial value
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Initial Value: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                             
                                    TextField("$0", value: $historicalCagrVM.initialAmount, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(historicalCagrVM.initialAmount == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .first)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                        
                                PortfolioCostBasisButtonView(costBasis: $historicalCagrVM.initialAmount)
                                
                                Text(historicalCagrVM.initialAmountPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Final Value
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Final Value: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    TextField("$0", value: $historicalCagrVM.endAmount, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(historicalCagrVM.endAmount == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .second)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                
                                PortfolioValueButtonView(value: $historicalCagrVM.endAmount)
                                
                                Text(historicalCagrVM.endAmountPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Num of years
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Years: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $historicalCagrVM.numOfYears, format: .number)
                                        .foregroundStyle(historicalCagrVM.numOfYears == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .third)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                            
                                Text(historicalCagrVM.yearsPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                        }
                        .padding()
                        .background(BackgroundRoundedRectangleView())
                        .padding(.horizontal, 5)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                InputKeyboard(focusedField: $focusedField, numOfFields: 3)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    if historicalCagrVM.allValidInputs {
                        finalResult
                    }
                }
                .padding([.top, .horizontal])
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            
            .navigationTitle(calculator.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        calculator.image
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(width: 35, height: 35, alignment: .leading)
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

extension HistoricalCagrView {
    private var finalResult: some View {
        VStack {
            Text("Historical CAGR")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack {
                VStack(spacing: 4) {
                    (Text("Over the course of ").foregroundStyle(themeVM.textColorTheme.primaryText) + Text(String(historicalCagrVM.numOfYears ?? 0)).foregroundStyle(themeVM.textColorTheme.primaryPopColor).fontWeight(.bold) + Text(" years, your compound annual growth rate was ").foregroundStyle(themeVM.textColorTheme.primaryText) + Text(historicalCagrVM.historicalCagr).foregroundStyle(themeVM.textColorTheme.primaryPopColor).fontWeight(.bold) + Text(".").foregroundStyle(themeVM.textColorTheme.primaryText))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                }
                .padding(.bottom)
                
                HStack(spacing: 0) {
                    Text("Note: This value is only an approximation. Slight changes to input parameters can drastically affect the output.")
                }
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.bottom)
    }
}
