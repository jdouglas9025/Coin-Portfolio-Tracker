import SwiftUI

// Reusable view for a portfolio value button -- used in calculator views
struct PortfolioValueButtonView: View {
    @EnvironmentObject private var primaryVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    @Binding var value: Int?
    
    var body: some View {
        Button(action: {
            let key = primaryVM.selectedPortfolioId
            value = Int(primaryVM.portfolios[key]?.1 ?? 0.0)
        }, label: {
            Text("Portfolio Value")
        })
            .font(.headline)
            .foregroundStyle(themeVM.textColorTheme.primaryText)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
