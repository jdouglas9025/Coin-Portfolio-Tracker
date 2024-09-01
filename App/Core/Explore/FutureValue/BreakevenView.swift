import SwiftUI
import Charts

// Allows user to calculate breakeven point for an investment
struct BreakevenView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var breakevenVM: BreakevenViewModel
    
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
                                (Text("1.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the current value of your portfolio.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                (Text("2.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" Enter the cost basis of your portfolio (i.e., total amount invested).").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical)
                                
                                (Text("3.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) + Text(" For additional insight, enter an estimated compound annual growth rate (CAGR). This is the rate that your portfolio grows at each year. This value allows the calculator to approximate the number of years until your portfolio will breakeven.").foregroundStyle(themeVM.textColorTheme.secondaryText))
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
                                    Text("Current Value: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                 
                                    TextField("$0", value: $breakevenVM.currentValue, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(breakevenVM.currentValue == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .first)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                        
                                PortfolioValueButtonView(value: $breakevenVM.currentValue)
                                
                                Text(breakevenVM.currentValuePrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Cost basis
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Cost Basis: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    TextField("$0", value: $breakevenVM.costBasis, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(breakevenVM.costBasis == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .second)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                
                                PortfolioCostBasisButtonView(costBasis: $breakevenVM.costBasis)
                                
                                Text(breakevenVM.costBasisPrompt)
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
                                        TextField("0.0%", value: $breakevenVM.growthRate, format: .number)
                                            .foregroundStyle(breakevenVM.growthRate == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                            .focused($focusedField, equals: .third)
                                            .keyboardType(.numberPad)
                                        
                                        if breakevenVM.growthRate != nil {
                                            Text("%")
                                                .foregroundStyle(themeVM.textColorTheme.primaryText)
                                        }
                                    }
                                }
                                .font(.headline)
                    
                                Text(breakevenVM.growthRatePrompt)
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
                    
                    if breakevenVM.allValidInputs {
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

extension BreakevenView {
    private var finalResult: some View {
        VStack {
            Text("Results")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack(spacing: 10.0) {
                VStack {
                    HStack {
                        Text("Breakeven Point: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(breakevenVM.breakevenPoint)
                            .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("Change: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(breakevenVM.breakevenChange)
                            .foregroundStyle(themeVM.textColorTheme.positive)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                   
                    HStack {
                        Text("% Change: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(breakevenVM.breakevenChangePercentage)
                            .foregroundStyle(themeVM.textColorTheme.positive)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    Divider()
                    
                    if breakevenVM.growthRate != nil {
                        HStack {
                            Text("Years until Breakeven: ")
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            Text(breakevenVM.numOfYearsUntilBreakeven)
                                .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.headline)
                        .padding(.top)
                        
                        Divider()
                    }
                }
                .padding()
                .background(BackgroundRoundedRectangleView())
                .padding(.horizontal, 5)
                
                // Chart (if growth rate specified)
                if breakevenVM.growthRate != nil {
                    VStack(spacing: 4) {
                        // Chart of annual values
                        Text("Annual Values")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                            .fontWeight(.bold)
                        
                        CustomLineChartView(themeVM: themeVM, data: breakevenVM.annualValuesUntilBreakeven)
                            .frame(height: 300)
                            .padding(.top, 75)
                            .padding(.trailing, 7.5)
                    }
                    .padding(.vertical)
                }
                
                HStack(spacing:0) {
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
