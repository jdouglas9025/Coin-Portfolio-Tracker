import Foundation

// Model for representing a capital gain in bar chart data -- either short-term or long term with type of federal or NIIT
struct CapitalGain {
    let id = UUID().uuidString
    
    let taxSystem: TaxSystem
    let taxType: TaxType
    // Total amount
    let total: Double
    
    enum TaxSystem: String {
        case shortTerm = "Short-Term", longTerm = "Long-Term"
    }
    
    enum TaxType: String {
        case federal = "Federal", NIIT = "NIIT"
    }
}
