import SwiftUI
import Charts

// Creates an area chart based on the provided params -- useful for visualizing change in value over time (i.e., portfolio value / last 7 days)
struct CustomAreaChartView: View {
    @ObservedObject private var themeVM: ThemeViewModel
    
    private let data: [Double]
    private let minY: Double
    private let maxY: Double
    private let endY: Double
    private let numOfPeriods: Int
    // Date when sparkline data was last updated (chart data is accurate till this point)
    private let periodEnd: Date
    
    private let lineWidth = 1.0
    private let lineForegoundStyle: Color
    private let lineShadowColor: Color
    
    // Optional threshold to use as a horizontal line (used in goal view)
    private let threshold: Double?
    
    private let ruleMarkTitle: String
    
    @State private var rawSelectedX: Double?
    
    private var selectedX: Int? {
        guard let rawSelectedX else { return nil }
        
        return Int(rawSelectedX)
    }
    
    // Get y-coordinate based on x-coordinate
    private var selectedY: Double? {
        guard let selectedX else { return nil }
        
        if (selectedX >= 0 && selectedX < numOfPeriods) {
            return data[selectedX]
        } else {
            return nil
        }
    }
    
    // Get change in current Y over previous Y (value change)
    private var changeInY: Double? {
        guard let selectedX else { return nil }
        
        let previousX = selectedX - 1
        
        if (previousX >= 0 && previousX < numOfPeriods) && (selectedX >= 0 && selectedX < numOfPeriods) {
            return data[selectedX] - data[previousX]
        } else {
            return nil
        }
    }
    
    init(themeVM: ThemeViewModel, periodValues: [Double], periodEnd: Date) {
        self.themeVM = themeVM
        data = periodValues
        
        minY = periodValues.min() ?? 0.0
        maxY = periodValues.max() ?? 0.0
        endY = minY * 0.99
        numOfPeriods = periodValues.count
    
        self.periodEnd = periodEnd
        
        let netPriceChange = (periodValues.last ?? 0.0) - (periodValues.first ?? 0.0)
        let color = (netPriceChange > 0) ? themeVM.textColorTheme.positive : (netPriceChange == 0) ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative
        
        lineForegoundStyle = color
        lineShadowColor = color
        
        threshold = nil
        ruleMarkTitle = "Time: "
    }
    
    // Constructor for goal performance overview
    init(themeVM: ThemeViewModel, periodValues: [Double], periodEnd: Date, threshold: Double) {
        self.themeVM = themeVM
        self.threshold = threshold
        data = periodValues
        
        let minPeriodValue = periodValues.min() ?? 0.0
        let maxPeriodValue = periodValues.max() ?? 0.0
        
        minY = min(minPeriodValue, threshold)
        maxY = max(maxPeriodValue, threshold)
        
        endY = minPeriodValue * 0.99
        numOfPeriods = periodValues.count
        self.periodEnd = periodEnd
        
        let netPriceChange = (periodValues.last ?? 0.0) - (periodValues.first ?? 0.0)
        let color = (netPriceChange > 0) ? themeVM.textColorTheme.positive : (netPriceChange == 0) ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative
        
        lineForegoundStyle = color
        lineShadowColor = color
        
        ruleMarkTitle = "Time: "
    }
    
    var body: some View {
        if data.count == 0 {
            Text("Unable to load chart. Please try again.")
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        } else {
            Chart {
                // Main lines
                ForEach(data.indices, id: \.self) { i in
                    // Create an area layer below line
                    // Set end Y to slightly less than min Y to give extra space under curve
                    AreaMark(x: .value("Index", i), yStart: .value("Value", data[i]), yEnd: .value("Bottom Value", endY))
                        .foregroundStyle(lineForegoundStyle.opacity(0.5))
                    
                    LineMark(
                        x: .value("Index", i),
                        y: .value("Value", data[i])
                    )
                    .lineStyle(StrokeStyle(lineWidth: lineWidth))
                    .foregroundStyle(lineForegoundStyle)
                    // Set shadow to very small to prevent blur
                    .shadow(color: lineShadowColor, radius: 0.25)
                }
                
                // Threshold horizontal line (outside ForEach loop -- causes issue otherwise)
                if let threshold {
                    RuleMark(y: .value("Goal Threshold", threshold))
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .offset(yStart: -10)
                        // Place above graph
                        .zIndex(1)
                        .opacity(0.50)
                        .annotation(
                            position: .top,
                            spacing: 0
                        ) {
                            HStack {
                                Text("Goal: ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                Text(threshold.asCondensedCurrency()).foregroundStyle(themeVM.textColorTheme.primaryText)
                            }
                            .font(.headline)
                    }
                }
            
                // Vertical rule mark (outside ForEach loop -- causes issue otherwise)
                if let selectedX {
                    RuleMark(x: .value("Selected index", selectedX))
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        // Set position based on whether threshold is present (prevent overlap)
                        .offset(yStart: threshold != nil ? -20 : -10)
                        .zIndex(-1)
                        .opacity(0.20)
                        .annotation(
                            position: .top,
                            spacing: 0,
                            overflowResolution: .init(
                                x: .fit(to: .chart),
                                // Allow y to be out of chart
                                y: .disabled
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 4.0) {
                                Text(ruleMarkTitle).foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                Text(getDate(index: selectedX).formatted(GeneralUtility.chartDateFormatter)).foregroundStyle(themeVM.textColorTheme.primaryText)
                                
                                // Show value and change since previous year
                                HStack(spacing: 0) {
                                    Text("Value: ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                    Text((selectedY?.asCurrency() ?? "$0.0")).foregroundStyle(themeVM.textColorTheme.primaryText)
                                    
                                    Text(" (")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                    
                                    let changeInY = changeInY ?? 0.0
                                    
                                    Text(changeInY.asFormattedNumberChange())
                                        .foregroundStyle(changeInY > 0 ? themeVM.textColorTheme.positive : changeInY == 0 ? themeVM.textColorTheme.unchanged : themeVM.textColorTheme.negative)
                                    Text(")")
                                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        }
                }
            }
            // X-axis should be -1 since 0-indexed and inclusive range
            .chartXScale(domain: [0, numOfPeriods - 1])
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    // Cast index into int
                    let index = $0.as(Int.self) ?? 0
                    let value = getDate(index: index).formatted(GeneralUtility.chartDateFormatter)
                    
                    AxisValueLabel {
                        Text(value)
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            // Slight padding to push line off X-Axis
                            .padding(.top, 5)
                    }
                }
            
            }
            // Set bottom of domain to slightly below min
            .chartYScale(domain: [endY, maxY])
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) {
                    // Cast value into double
                    let value = ($0.as(Double.self) ?? 0.0).asCondensedCurrency()
                    
                    AxisValueLabel {
                        Text(value)
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            // Slight padding to push line off Y-Axis
                            .padding(.trailing, 5)
                    }
                }
            }
            // Makes points selectable
            .chartXSelection(value: $rawSelectedX)
        }
    }
    
    // Gets the corresponding date based on an index and last sparkline update time
    private func getDate(index: Int) -> Date {
        let calendar = Calendar.current
        
        // Get number of hours ago based on index (index 0 is 168 hours ago)
        let hoursAgo = (numOfPeriods - 1 - index)
        let hourComponent = DateComponents(hour: -hoursAgo)
        
        // Return last sparkline update time offset by current index
        return calendar.date(byAdding: hourComponent, to: periodEnd) ?? periodEnd
    }
}
