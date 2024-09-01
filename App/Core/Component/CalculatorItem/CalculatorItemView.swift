import SwiftUI

// Represents the view for a calculator item in the explore view grid
struct CalculatorItemView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    // Current explore item to display
    let calculator: Calculator
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(calculator.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                calculator.image
            }
            .font(.headline)
            .foregroundStyle(themeViewModel.textColorTheme.primaryText)
            
            Text(calculator.caption)
                .font(.subheadline)
                .foregroundStyle(themeViewModel.textColorTheme.secondaryText)
        }
    }
}
