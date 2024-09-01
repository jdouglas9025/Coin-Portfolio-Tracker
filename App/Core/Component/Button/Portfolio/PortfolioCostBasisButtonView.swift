import SwiftUI

// Reusable view for a portfolio cost basis button -- used in calculator views
struct PortfolioCostBasisButtonView: View {
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var costBasis: Int?
    
    var body: some View {
        Button(action: {
            let key = primaryVM.selectedPortfolioId
            costBasis = Int(primaryVM.portfolios[key]?.2 ?? 0.0)
        }, label: {
            Text("Portfolio Cost Basis")
        })
            .font(.headline)
            .foregroundStyle(themeVM.textColorTheme.primaryText)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
