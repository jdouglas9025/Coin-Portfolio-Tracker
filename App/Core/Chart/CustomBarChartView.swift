import SwiftUI
import Charts

// Creates a bar chart for capital gains calculator results
struct CustomBarChartView: View {
    @ObservedObject private var themeVM: ThemeViewModel
    
    private let data: [CapitalGain]
    private let minY: Double
    private let maxY: Double

    @State private var selectedTaxSystem: String?
    @State private var selectedFederalTotal: Double?
    @State private var selectedNIITTotal: Double?
    
    init(themeVM: ThemeViewModel, data: [CapitalGain]) {
        self.themeVM = themeVM
        self.data = data

        minY = data.min(by: { $0.total < $1.total })?.total ?? 0.0
        maxY = data.max(by: { $0.total < $1.total })?.total ?? 0.0
    }
    
    var body: some View {
        if data.count == 0 {
            Text("Unable to load chart. Please try again.")
                .font(.caption)
                .foregroundStyle(themeVM.textColorTheme.secondaryText)
        } else {
            Chart {
                ForEach(data, id: \.id) { capitalGain in
                    // Create stacked bar chart -- each aggregate bar includes federal rate + NIIT
                    BarMark(
                        x: .value("Tax System", capitalGain.taxSystem.rawValue),
                        y: .value("Total Tax", capitalGain.total)
                    )
                    .foregroundStyle(capitalGain.taxType == .federal ? themeVM.textColorTheme.primaryPopColor : themeVM.textColorTheme.secondaryPopColor)
                    .shadow(color: capitalGain.taxType == .federal ? themeVM.textColorTheme.primaryPopColor : themeVM.textColorTheme.secondaryPopColor, radius: 2.0)
                }
            
                // Vertical rule mark
                if let selectedTaxSystem,
                   let selectedFederalTotal,
                   let selectedNIITTotal {
                    RuleMark(x: .value("Selected Tax System", selectedTaxSystem))
                        .foregroundStyle(themeVM.textColorTheme.secondaryText)
                        .offset(yStart: -10)
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
                            VStack(spacing: 10.0) {
                                Text(selectedTaxSystem)
                                    .foregroundStyle(themeVM.textColorTheme.primaryText)
                                
                                VStack(alignment: .leading) {
                                    if selectedNIITTotal > 0.0 {
                                        Text("NIIT: ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                        Text(selectedNIITTotal.asCurrency()).foregroundStyle(themeVM.textColorTheme.secondaryPopColor)
                                    }
                                    
                                    if selectedFederalTotal > 0.0 {
                                        Text("Federal: ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                        Text(selectedFederalTotal.asCurrency()).foregroundStyle(themeVM.textColorTheme.primaryPopColor)
                                    }
                                    
                                    let total = selectedNIITTotal + selectedFederalTotal
                                    Text("Total: ").foregroundStyle(themeVM.textColorTheme.secondaryText) +
                                    Text(total.asCurrency()).foregroundStyle(themeVM.textColorTheme.primaryText)
                                }
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned) {
                    let value = $0.as(String.self) ?? ""
                    
                    AxisValueLabel {
                        Text(value)
                            .font(.caption)
                            .foregroundStyle(themeVM.textColorTheme.secondaryText)
                            // Slight padding to push line off X-Axis
                            .padding(.top, 5)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .aligned, position: .leading) {
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
            // Allow user to select bar -- use gesture with onEnded to allow click-off
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(DragGesture() 
                                .onChanged { value in
                                    updateSelectedTaxSystem(location: value.location, proxy: proxy, geometry: geometry)
                                }
                                .onEnded { _ in
                                    // Reset to hide rule mark
                                    selectedTaxSystem = nil
                                    selectedFederalTotal = nil
                                    selectedNIITTotal = nil
                                }
                            )
                    }
                }
            }
        }
    }
    
    // Gets the selected bar data based on x-coordinate
    private func updateSelectedTaxSystem(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        guard let plotFrame = proxy.plotFrame else { return }
        
        let xPos = location.x - geometry[plotFrame].origin.x
        
        guard let taxSystem: String = proxy.value(atX: xPos) else { return }
        
        selectedTaxSystem = taxSystem
        selectedFederalTotal = data.first(where: {$0.taxSystem.rawValue == taxSystem && $0.taxType == .federal})?.total
        selectedNIITTotal = data.first(where: {$0.taxSystem.rawValue == taxSystem && $0.taxType == .NIIT})?.total
    }
}
