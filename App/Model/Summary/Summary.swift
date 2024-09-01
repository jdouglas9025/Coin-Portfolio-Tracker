import Foundation
import SwiftUI

// Represents a reusable summary component for displaying high-level statistic data with a format of currency
// E.g., portfolio value change
struct CurrencySummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: Double
    // Determines whether formatting should be change-specific
    let isChange: Bool
    
    init(title: String, value: Double, isChange: Bool) {
        self.title = title
        self.value = value
        self.isChange = isChange
        
        if isChange {
            // Choose appropriate color
            foregoundColor = (value > 0) ? .positive : (value == 0) ? .unchanged : .negative
        } else {
            foregoundColor = .primaryText
        }
    }
    
    func getFormattedValue() -> String {
        return value.asCurrency()
    }
}

// Represents a reusable summary component for displaying high-level statistic data with a format of condensed currency
// E.g., portfolio value change
struct CondensedCurrencySummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: Double
    
    func getFormattedValue() -> String {
        return value.asCondensedCurrency()
    }
}

// Represents a reusable summary component for displaying high-level statistic data with a format of condensed double (non-currency) that has changed (positive or negative)
// E.g., portfolio value change on portfolio management screen where space is limited
struct CondensedDoubleSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor
    
    let value: Double
    let isChange: Bool
    
    init(title: String, value: Double, isChange: Bool) {
        self.title = title
        self.value = value
        self.isChange = isChange
        
        if isChange {
            foregoundColor = (value > 0) ? .positive : (value == 0) ? .unchanged : .negative
        } else {
            foregoundColor = .primaryText
        }
    }
    
    func getFormattedValue() -> String {
        return value.asCondensedNumber()
    }
}

// Represents a reusable summary component for displaying high-level statistic data with a format of standard double (up to 4 decimal places)
// E.g., portfolio value change
struct DoubleSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor
    
    let value: Double
    let isChange: Bool
    
    init(title: String, value: Double, isChange: Bool) {
        self.title = title
        self.value = value
        self.isChange = isChange
        
        if isChange {
            foregoundColor = (value > 0) ? .positive : (value == 0) ? .unchanged : .negative
        } else {
            foregoundColor = .primaryText
        }
    }
    
    func getFormattedValue() -> String {
        return value.asFormattedNumber()
    }
}

// Represents a reusable summary component for displaying high-level statistic data with a format of percentage
// E.g., portfolio percent change
struct PercentSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: Double
    
    let isChange: Bool
    
    init(title: String, value: Double, isChange: Bool) {
        self.title = title
        self.value = value
        self.isChange = isChange
        
        if isChange {
            foregoundColor = value > 0 ? .positive : value == 0 ? .unchanged : .negative
        }
    }
    
    func getFormattedValue() -> String {
        return value.asPercentage(isChange: isChange)
    }
}

// Represents a reusable summary component for displaying date value data as a string
// E.g., all time high, genesis date for a coin
struct DateSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: String
    let dateType: String.DateType
    
    func getFormattedValue() -> String {
        return value.asFormattedDate(dateType: dateType)
    }
}

// Represents a reusable summary component for displaying string data
struct StringSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: String
    
    func getFormattedValue() -> String {
        return value
    }
}

// Represents a reusable summary component for displaying string data with a clickable URL
struct UrlSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: String
    let url: URL?
    
    func getFormattedValue() -> String {
        return value
    }
}

// Represents a reusable summary component for displaying high-level statistic data with a format of integer
// E.g., market cap rank
struct IntSummary: Summarizable {
    var id = UUID().uuidString
    var title: String
    var foregoundColor: ForegroundColor = .primaryText
    
    let value: Int
    
    // Whether to display value as 2K or 2,000
    let isCondensed: Bool
    
    func getFormattedValue() -> String {
        if isCondensed {
            return value.asCondensedNumber()
        } else {
            return value.formatted()
        }
    }
}
