import SwiftUI
import Charts

// Allows user to estimate federal capital gains on the sale of an investment
struct CapitalGainsView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var capitalGainsVM: CapitalGainsViewModel
    
    // Used to pull information about this item
    let calculator: Calculator
    
    private let lineLimit = 3
    @State private var showNIITNote = false
    
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
                                (Text("1.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                                    Text(" Enter the sale value of your portfolio.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                
                                (Text("2.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                                    Text(" Enter the cost basis of your portfolio (i.e., total amount invested).").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical)
                                
                                (Text("3.").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                                    Text(" For additional insight, enter your total income for the year (excluding this sale). For example, if you earn $50,000 per year, enter that amount to ensure your capital gain is taxed at the appropriate rate.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom)
                                
                                (Text("Notes:").foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                                    Text("\n> Investments sold over a year after their purchase date are considered long-term capital gains by the IRS and are taxed at special rates.\n> In addition to standard federal taxes, a Net Investment Income Tax (NIIT) may apply to capital gains above a certain threshold.").foregroundStyle(themeVM.textColorTheme.secondaryText))
                                        .lineLimit(showNIITNote ? nil : lineLimit)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.easeInOut) {
                                                showNIITNote.toggle()
                                            }
                                        }
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
                            // Sale value
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Sale Value: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                 
                                    TextField("$0", value: $capitalGainsVM.saleValue, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(capitalGainsVM.saleValue == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .first)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                    
                                PortfolioValueButtonView(value: $capitalGainsVM.saleValue)
                                
                                Text(capitalGainsVM.saleValuePrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Cost Basis
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Cost Basis: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                  
                                    TextField("$0", value: $capitalGainsVM.costBasis, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(capitalGainsVM.costBasis == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .second)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                                
                                PortfolioCostBasisButtonView(costBasis: $capitalGainsVM.costBasis)
                                
                                Text(capitalGainsVM.costBasisPrompt)
                                    .font(.caption)
                                    .foregroundStyle(themeVM.textColorTheme.negative)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                            }
                            .multilineTextAlignment(.trailing)
                            .padding(.bottom)
                            
                            // Yearly income
                            VStack(alignment: .leading, spacing: 4.0) {
                                HStack {
                                    Text("Yearly Income: ")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    Spacer()
                                    
                                    TextField("$0", value: $capitalGainsVM.yearlyIncome, format: GeneralUtility.intCurrencyFormatter)
                                        .foregroundStyle(capitalGainsVM.yearlyIncome == nil ? themeVM.textColorTheme.secondaryText : themeVM.textColorTheme.primaryText)
                                        .focused($focusedField, equals: .third)
                                        .keyboardType(.numberPad)
                                }
                                .font(.headline)
                    
                                Text(capitalGainsVM.yearlyIncomePrompt)
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
                    
                    if capitalGainsVM.allValidInputs {
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

extension CapitalGainsView {
    private var finalResult: some View {
        VStack {
            Text("Results")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack(spacing: 10.0) {
                // Short-term results
                VStack(spacing: 5.0) {
                    HStack {
                        Text("Short-Term Gain")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    
                    if capitalGainsVM.shortTermFederalCapitalGainTax > 0.0 {
                        Divider()
                            .padding(.bottom)
                        
                        HStack {
                            Text("Federal Tax: ")
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            Text(capitalGainsVM.shortTermFederalCapitalGainTax.asCurrency())
                                .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                        }
                        .font(.headline)
                    }
                    
                    if capitalGainsVM.netInvestmentIncomeTax > 0.0 {
                        HStack {
                            Text("Net Investment Income Tax: ")
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            Text(capitalGainsVM.netInvestmentIncomeTax.asCurrency())
                                .foregroundStyle(themeVM.textColorTheme.secondaryPopColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                        }
                        .font(.headline)
                    }
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("Total Liability: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.shortTermTotalCapitalGainTax.asCurrency())
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    HStack {
                        Text("Effective Tax Rate: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.shortTermTotalCapitalGainTaxEffectiveRate.asPercentage(isChange: false))
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("Amount After Tax: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.shortTermTotalAmountAfterTax.asCurrency())
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    Divider()
                }
                .padding()
                .background(BackgroundRoundedRectangleView())
                .padding(.horizontal, 5)
                
                // Long-term results
                VStack(spacing: 5.0){
                    HStack {
                        Text("Long-Term Gain")
                    }
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                    
                    if capitalGainsVM.longTermFederalCapitalGainTax > 0.0 {
                        Divider()
                            .padding(.bottom)
                        
                        HStack {
                            Text("Federal Tax: ")
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            Text(capitalGainsVM.longTermFederalCapitalGainTax.asCurrency())
                                .foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                        }
                        .font(.headline)
                    }
                    
                    if capitalGainsVM.netInvestmentIncomeTax > 0.0 {
                        HStack {
                            Text("Net Investment Income Tax: ")
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            
                            Spacer()
                            
                            Text(capitalGainsVM.netInvestmentIncomeTax.asCurrency())
                                .foregroundStyle(themeVM.textColorTheme.secondaryPopColor)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                        }
                        .font(.headline)
                    }
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("Total Liability: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.longTermTotalCapitalGainTax.asCurrency())
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    HStack {
                        Text("Effective Tax Rate: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.longTermTotalCapitalGainTaxEffectiveRate.asPercentage(isChange: false))
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack {
                        Text("Amount After Tax: ")
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        
                        Spacer()
                        
                        Text(capitalGainsVM.longTermTotalAmountAfterTax.asCurrency())
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.headline)
                    
                    Divider()
                }
                .padding()
                .background(BackgroundRoundedRectangleView())
                .padding(.horizontal, 5)
                
                // Comparsion of results
                VStack(alignment: .leading, spacing: 5.0) {
                    (Text("For a capital gain of ").foregroundStyle(themeVM.textColorTheme.secondaryText) +     Text(capitalGainsVM.capitalGain.asCurrency()).foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                        Text(", you would save approximately ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                        Text(capitalGainsVM.totalCapitalGainTaxSavings.asCurrency()).foregroundStyle(themeVM.textColorTheme.primaryText).fontWeight(.bold) +
                        Text(" with long-term tax rates").foregroundStyle(themeVM.textColorTheme.secondaryText))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                                    
                    // Only show chart if at least one liability > 0
                    if (capitalGainsVM.shortTermTotalCapitalGainTax > 0.0 || capitalGainsVM.longTermTotalCapitalGainTax > 0.0) {
                        Text("Short-Term vs. Long-Term Liabilities")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .fontWeight(.bold)
                        
                        CustomBarChartView(themeVM: themeVM, data: capitalGainsVM.chartData)
                            // Charts should have height of 300
                            .frame(height: 300)
                            // Padding for annotation
                            .padding(.top, 120)
                            // Padding for right x-axis
                            .padding(.trailing, 10)
                    }
                }
                .font(.headline)
                .padding([.top, .bottom])
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 10.0) {
                    Text("Note: This result is only an approximation and may be inaccurate. For example, this calculator does not consider state or local tax rates (likely applicable to many investors) or many tax deductions. Furthermore, it utilizes single filer tax brackets with the standard deduction included, which may not apply to your situation. Please consult with a licensed tax professional before making any tax-related decisions.")
                }
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            }
        }
        .padding(.bottom)
    }
}
