import Foundation
import SwiftUI

// General purpose utility class
struct GeneralUtility {
    // Base URL of backend server
    static let serverBaseUrl = "https://simplecoinportfolio.glasengineering.com:8443"
    
    // Approximate S&P 500 CAGR over last 10 years -- rounded slightly down
    static let sp500GrowthRate = 12.0
    
    static var intCurrencyInputFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_us")
        formatter.usesGroupingSeparator = true
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter
    }
    
    static var intInputFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter
    }
   
    static var decimalInputFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        
        return formatter
    }
    
    static var intCurrencyFormatter: IntegerFormatStyle<Int>.Currency {
        IntegerFormatStyle.Currency(code: "USD", locale: Locale(identifier: "en_us")).precision(.fractionLength(0))
    }
    
    // Formats decimals into condensed form (up to 3x before/2x places after decimal)
    // Used with both numbers and currency
    // Requires at least one leading digit (e.g., $0.13 instead of $.13)
    static var condensedDecimalFormatter: FloatingPointFormatStyle<Double> {
        .number.notation(.compactName)
        .precision(.integerAndFractionLength(integerLimits: 1...3, fractionLimits: 0...2))
    }
    
    // Formats ints into condensed form (e.g., 2,000 -> 2K)
    static var condensedIntFormatter: IntegerFormatStyle<Int> {
        .number.notation(.compactName)
        .precision(.integerLength(0...3))
    }
    
    // Formatter for dates inside price charts
    static var chartDateFormatter: Date.FormatStyle {
        Date.FormatStyle()
            .month(.defaultDigits)
            .day(.defaultDigits)
            .hour(.defaultDigits(amPM: .abbreviated))
    }
    
    // Formatter for short dates (e.g., last refresh times)
    static var shortDateFormatter: Date.FormatStyle {
        Date.FormatStyle()
            .month(.defaultDigits)
            .day(.defaultDigits)
            .hour(.defaultDigits(amPM: .abbreviated))
            .minute(.defaultDigits)
    }
    
    // Formatter for converting raw news dates from API response to date objects in news feed service
    static var newsDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        
        return formatter
    }
    
    // Formatter for converting last updated dates
    // Sample: "2024-01-26T17:02:43.515707"
    static var lastUpdatedDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        return formatter
    }
    
    // '^[1-9]' requires the first digit be 1 through 9; '[0-9]{0,11}$' requires any remaining digits be 0 through 9 (max 9) -- min is 1 and max is 1 billion
    static var amountPredicate: NSPredicate {
        NSPredicate(format: "SELF MATCHES %@", "^[1-9][0-9]{0,9}$")
    }
    
    // Max digits is 3 (max input 999)
    static var yearsPredicate: NSPredicate {
        NSPredicate(format: "SELF MATCHES %@", "^[1-9][0-9]{0,2}$")
    }
    
    // At least 1 digit while total max is 7 digits with up to 4 after decimal -- max input 9999999
    static var growthRatePredicate: NSPredicate {
        NSPredicate(format: "SELF MATCHES %@", "^(?=(?:[0-9]\\.?){1,7}$)\\d+(?:\\.\\d{1,4})?$")
    }
    
    // At least 1 digit while total max is 9 digits with up to 6 after decimal -- max input 999,999,999
    static var holdingsPredicate: NSPredicate {
        NSPredicate(format: "SELF MATCHES %@", "^(?=(?:[0-9]\\.?){1,9}$)\\d+(?:\\.\\d{1,6})?$")
    }
    
    static let growthRateLimit = 500.00
}
