import SwiftUI

struct SummaryView: View {
    @EnvironmentObject private var themeViewModel: ThemeViewModel
    // Current summary item to display
    let summary: Summarizable
    
    var foregroundColor: Color {
        switch(summary.foregoundColor) {
            case .primaryText:
               return themeViewModel.textColorTheme.primaryText
            case .positive:
                return themeViewModel.textColorTheme.positive
            case .unchanged:
                return themeViewModel.textColorTheme.unchanged
            case .negative:
                return themeViewModel.textColorTheme.negative
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(summary.title)
                .font(.caption)
                .foregroundStyle(themeViewModel.textColorTheme.secondaryText)
            
            // Display formatted value
            Text(summary.getFormattedValue())
                .font(.headline)
                .foregroundStyle(foregroundColor)
        }
        .multilineTextAlignment(.leading)
    }
}
