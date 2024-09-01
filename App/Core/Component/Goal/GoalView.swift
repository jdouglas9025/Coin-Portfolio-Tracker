import SwiftUI

// Represents a goal item from the current portfolio
struct GoalView: View {
    @EnvironmentObject private var homeVM: PrimaryViewModel
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let goal: Goal
    let showFullAmount: Bool
    
    var progress: Double {
        let target = goal.goalTarget
        let current = homeVM.portfolios[homeVM.selectedPortfolioId]?.1 ?? 0.0
        
        return current / target
    }
    
    var difference: String {
        let difference = goal.goalTarget - (homeVM.portfolios[homeVM.selectedPortfolioId]?.1 ?? 0.0)
        
        if difference > 0.0 {
            return difference.asCondensedCurrency()
        } else {
            return "Done!"
        }
    }

    var daysTill: Int {
        // Get current user's calendar
        let calendar = Calendar.current
        
        guard let date = goal.goalDate else { return 0 }
        return calendar.numberOfDaysBetween(from: Date.now, to: date)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(goal.goalDescription ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Divider()
            }
            .foregroundStyle(themeVM.textColorTheme.primaryText)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.leading)
            
            HStack {
                VStack(alignment: .center, spacing: 5.0) {
                    if showFullAmount {
                        Text(goal.goalTarget.asCurrency())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(goal.goalTarget.asCondensedCurrency())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(themeVM.textColorTheme.primaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Remaining time
                    if daysTill > 0 {
                        if progress >= 1 {
                            // Target already met with time to spare
                            Text(daysTill.formatted() + " Days to Spare!")
                                .font(.caption)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        } else {
                            Text(daysTill.formatted() + " Days Remaining")
                                .font(.caption)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        if progress < 1 {
                            // No time left and did not complete goal
                            Text("Time's Up!")
                                .font(.caption)
                                .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
       
                // Progress ring
                ZStack {
                    // Base
                    Circle()
                        .stroke(themeVM.textColorTheme.primaryPopColor, lineWidth: 8.0)
                    
                    // Progress overlay
                    Circle()
                        // TO DO: add trim animation effect
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [themeVM.textColorTheme.secondaryPopColor]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360.0 * progress)),
                            style: StrokeStyle(lineWidth: 8.0, lineCap: .round)
                        )
                        // Align
                        .rotationEffect(Angle(degrees: -90.0))
                        .overlay(
                            // Remaining
                            VStack(alignment: .center) {
                                Text(difference)
                                
                                if difference != "Done!" {
                                    Text("Remaining")
                                }
                            }
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            .font(.caption)
                        )
                }
                .frame(width: 80.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 5)
        }
    }
}
