import Foundation
import SwiftUI

// Represents the model for an calculator item inside the explore view
struct Calculator {
    let id = UUID().uuidString
    
    let type: CalculatorType
    
    enum CalculatorType {
        case futureValue, historicalCagr, breakeven, capitalGains
    }
    
    var title = ""
    var caption = ""
    var image = Image(systemName: "questionmark")
    
    init(type: CalculatorType) {
        self.type = type
        
        switch type {
            case .futureValue:
                setForFutureValue()
                
            case .historicalCagr:
                setForHistoricalCagr()
                
            case .breakeven:
                setForBreakeven()
                
            case .capitalGains:
                setForCapitalGains()     
        }
    }
    
    private mutating func setForFutureValue() {
        title = "Future Value"
        caption = "Estimates the future value of your portfolio using a provided compound annual growth rate (CAGR)"
        image = Image(systemName: "hourglass")
    }
    
    private mutating func setForHistoricalCagr() {
        title = "Historical CAGR"
        caption = "Calculates the historical compound annual growth rate (CAGR) for your portfolio over a certain time period"
        image = Image(systemName: "pencil.and.list.clipboard")
    }
    
    private mutating func setForBreakeven() {
        title = "Breakeven Point"
        caption = "Generates various statistics regarding your portfolio's breakeven point using your cost basis"
        image = Image(systemName: "dollarsign.arrow.circlepath")
    }
    
    private mutating func setForCapitalGains() {
        title = "Capital Gains"
        caption = "Estimates 2024 U.S. federal capital gains tax given a sale value and cost basis for your portfolio"
        image = Image(systemName: "banknote")
    }
}
