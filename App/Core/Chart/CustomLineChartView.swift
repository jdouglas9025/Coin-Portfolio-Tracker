import SwiftUI
import Charts

// Creates a line chart based on the provided params -- since a new chart view will be generated whenever data is changed externally, these fields should be constant
// Compared to area chart, this should be used when values do not go down over time -- no positive/negative theme color
struct CustomLineChartView: View {
    @ObservedObject private var themeVM: ThemeViewModel
    
    private let data: [Double]
    private let minY: Double
    private let maxY: Double
    private let numOfPeriods: Int
    
    private let lineWidth = 2.0
    private let lineForegoundStyle: Color
    private let lineShadowColor: Color
    private let showPoints: Bool
    
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
    
    init(themeVM: ThemeViewModel, data: [Double]) {
        self.themeVM = themeVM
        self.data = data

        minY = data.min() ?? 0.0
        maxY = data.max() ?? 0.0
        numOfPeriods = data.count
    
        lineForegoundStyle = themeVM.textColorTheme.primaryPopColor
        lineShadowColor = themeVM.textColorTheme.primaryPopColor
        
        showPoints = true
        ruleMarkTitle = "Year: "
    }
    
    var body: some View {
        if data.count == 0 {
            Text("Unable to load chart. Please try again.")
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        } else {
            Chart {
                ForEach(data.indices, id: \.self) { i in
                    // Creates a line connecting points
                    LineMark(
                        x: .value("Period", i),
                        y: .value("Value", data[i])
                    )
                    .lineStyle(StrokeStyle(lineWidth: lineWidth))
                    .foregroundStyle(lineForegoundStyle)
                    .shadow(color: lineShadowColor, radius: 2.0)
                    
                    // Create a circle at data points -- only show for certain charts
                    if showPoints {
                        PointMark(
                            x: .value("Period", i),
                            y: .value("Value", data[i])
                        )
                        .foregroundStyle(lineForegoundStyle)
                        .shadow(color: lineShadowColor, radius: 2.0)
                    }
                }
            
                // Vertical rule mark
                if let selectedX {
                    RuleMark(x: .value("Selected period", selectedX))
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .offset(yStart: -10)
                        // Ensure line is behind existing content
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
                                Text(String(selectedX)).foregroundStyle(themeVM.textColorTheme.primaryText)
                                
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
                    let value = $0.as(Int.self) ?? 0
                    
                    AxisValueLabel {
                        Text(String(value))
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            // Slight padding to push line off X-Axis
                            .padding(.top, 5)
                    }
                }
            
            }
            .chartYScale(domain: [minY, maxY])
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
}
