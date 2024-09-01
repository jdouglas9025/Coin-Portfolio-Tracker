import SwiftUI
import Charts

// Allows user to estimate future value of portfolio given a certain CAGR
struct FutureValueView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var futureValueVM: FutureValueViewModel
    
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
                                (Text("1.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter an amount to use as your starting value.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                (Text("2.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter an optional amount that you plan to invest each month.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical)
                                
                                (Text("3.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the number of years to forecast out. For example, if you are looking to see what your portfolio might be worth when you retire, you might enter a number such as 30.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.bottom)
                                
                                (Text("4.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter a compound annual growth rate. This is the rate that your portfolio grows at each year. If you aren't sure what rate to use, click the S&P 500 button to use the approximate rate for the S&P 500 index over the last decade.").foregroundStyle(themeVM.textColorTheme.secondaryText))
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
                            // Current value
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Initial Value: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                 
                                    TextField("$0", value: $futureValueVM.initialAmount, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(futureValueVM.initialAmount == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .first)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                
                                PortfolioValueButtonView(value: $futureValueVM.initialAmount)
                                
                                Text(futureValueVM.initialAmountPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Monthly investment
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Monthly Investment: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                 
                                    TextField("$0", value: $futureValueVM.monthlyContribution, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(futureValueVM.monthlyContribution == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .second)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                }
                                .font(.headline)
                                
                                Text(futureValueVM.monthlyContributionPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .padding(.bottom)
                            
                            // Number of years
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Years: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $futureValueVM.numOfYears, format: .number)
                                        .foregroundStyle(futureValueVM.numOfYears == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .third)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                
                                Text(futureValueVM.numOfYearsPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Growth rate
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Rate: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 0) {
                                        TextField("0.0%", value: $futureValueVM.growthRate, format: .number)
                                            .foregroundStyle(futureValueVM.growthRate == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                            .focused($focusedField, equals: .fourth)
                                            .keyboardType(.decimalPad)
                                        
                                        // Use if over opacity to prevent misalignment
                                        if futureValueVM.growthRate != nil {
                                            Text("%")
                                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                        }
                                    }
                                }
                                .font(.headline)
                                
                                Button(action: {
                                    futureValueVM.growthRate = GeneralUtility.sp500GrowthRate
                                }, label: {
                                    Text("S&P 500")
                                })
                                    .font(.headline)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                Text(futureValueVM.growthRatePrompt)
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
                                InputKeyboard(focusedField: $focusedField, numOfFields: 4)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    if futureValueVM.allValidInputs {
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

extension FutureValueView {
    private var finalResult: some View {
        VStack {
            Text("In " + String(futureValueVM.numOfYears ?? 0) + " years, your portfolio will be worth")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack {
                VStack(spacing: 4) {
                    Text(futureValueVM.finalValue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    // Chart of annual values
                    Text("Annual Values")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                        .fontWeight(.bold)
                    
                    CustomLineChartView(themeVM: themeVM, data: futureValueVM.annualValues)
                        .frame(height: 300)
                        .padding(.top, 75)
                        .padding(.trailing, 7.5)
                }
                .padding(.bottom)
                
                HStack(spacing: 0) {
                    Text("Note: This value is only an approximation. Slight changes to input parameters can drastically affect the outcome. To get a better overall estimate, consider analyzing multiple types of scenarios such as worst, so-so, and best case.")
                }
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.bottom)
    }
}
