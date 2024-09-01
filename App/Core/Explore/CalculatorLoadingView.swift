import SwiftUI

// Intermediate view that verifies the calculator item is not nil and generates the specific view for that type
// Required to prevent blank sheet issue
struct CalculatorLoadingView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    
    @StateObject private var futureValueVM = FutureValueViewModel()
    @StateObject private var historicalCagrVM = HistoricalCagrViewModel()
    @StateObject private var capitalGainsVM = CapitalGainsViewModel()
    @StateObject private var breakevenVM = BreakevenViewModel()
    
    @Binding var calculator: Calculator?
    
    var body: some View {
        if let calculator = calculator {
            switch calculator.type {
                case .futureValue:
                    FutureValueView(calculator: calculator)
                        .preferredColorScheme(themeVM.backgroundColorTheme)
                        .dynamicTypeSize(themeVM.textSizeTheme)
                        .environmentObject(themeVM)
                        .environmentObject(primaryVM)
                        .environmentObject(futureValueVM)
                    
                case .historicalCagr:
                    HistoricalCagrView(calculator: calculator)
                        .preferredColorScheme(themeVM.backgroundColorTheme)
                        .dynamicTypeSize(themeVM.textSizeTheme)
                        .environmentObject(themeVM)
                        .environmentObject(primaryVM)
                        .environmentObject(historicalCagrVM)
                    
                case .breakeven:
                    BreakevenView(calculator: calculator)
                        .preferredColorScheme(themeVM.backgroundColorTheme)
                        .dynamicTypeSize(themeVM.textSizeTheme)
                        .environmentObject(themeVM)
                        .environmentObject(primaryVM)
                        .environmentObject(breakevenVM)
                    
                case .capitalGains:
                    CapitalGainsView(calculator: calculator)
                        .preferredColorScheme(themeVM.backgroundColorTheme)
                        .dynamicTypeSize(themeVM.textSizeTheme)
                        .environmentObject(themeVM)
                        .environmentObject(primaryVM)
                        .environmentObject(capitalGainsVM)
            }
        }
    }
}
