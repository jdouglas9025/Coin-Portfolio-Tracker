import SwiftUI

// Represents the menu for selecting different timeframes for charts/period overviews throughout app
struct TimeframeMenuView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    var body: some View {
        Menu {
            ForEach(PrimaryViewModel.TimeframeOption.allCases, id: \.rawValue) { timeframeOption in
                Button {
                    homeVM.timeframeOption = timeframeOption
                } label: {
                    Text(timeframeOption.rawValue)
                        .font(.headline)
                        .foregroundStyle(themeVM.textColorTheme.primaryText)
                }
            }
        } label: {
            Text(homeVM.timeframeOption.rawValue)
                .font(.headline)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .padding(10)
                .background(BackgroundRoundedRectangleView())
        }
    }
}
