import Foundation

// Offers currency formatting methods for price data
extension Double {
    // Formatter for very large decimals (> 1000)
    private static var veryLargeNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter
    }
    
    // Formatter for large decimals (> 10)
    private static var largeNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    // Formatter for medium decimals (> 1)
    private static var mediumNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        
        return formatter
    }
    
    // Formatter for small decimals (> .10)
    private static var smallNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
    
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        
        return formatter
    }
    
    // Formatter for very small decimals (> .001)
    private static var verySmallNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 5
        
        return formatter
    }
    
    // Formatter for tiny decimals (< .001)
    private static var tinyNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        //Set min and max decimal places
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        
        return formatter
    }
    
    private static var percentageFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }
    
    // Converts a double (non-currency) into a condensed number representation
    func asCondensedNumber() -> String {
        return GeneralUtility.condensedDecimalFormatter.format(self)
    }
    
    // Returns a formatted number based on formatter logic
    private func customFormatted() -> String {
        // Convert calling double into NSNumber
        let number = NSNumber(value: self)
        
        // Take absolute value of number to handle negatives
        let magnitude = abs(self)
        
        // Set precision based on number magnitude
        if magnitude > 1000.0 {
            return Double.veryLargeNumberFormatter.string(from: number) ?? "0"
        } else if magnitude > 10.0 {
            return Double.largeNumberFormatter.string(from: number) ?? "0"
        } else if magnitude > 1.0 {
            return Double.mediumNumberFormatter.string(from: number) ?? "0"
        } else if magnitude > 0.10 {
            return Double.smallNumberFormatter.string(from: number) ?? "0"
        } else if magnitude > 0.001 {
            return Double.verySmallNumberFormatter.string(from: number) ?? "0"
        } else {
            return Double.tinyNumberFormatter.string(from: number) ?? "0"
        }
    }
    
    // Converts double into currency representation
    func asCurrency() -> String {
        return "$" + self.customFormatted()
    }
    
    // Converts double into condensed currency representation (uses 'B', 'M', etc.)
    func asCondensedCurrency() -> String {
        return "$" + GeneralUtility.condensedDecimalFormatter.format(self)
    }
    
    // Converts double into formatted number of type string with varying levels of digits after fraction -- for non-change numbers
    func asFormattedNumber() -> String {
        return self.customFormatted()
    }
    
    // Converts double into formatted number using asFormattedNumber() -- adds '+' for positive changes -- for change numbers
    func asFormattedNumberChange() -> String {
        if self > 0 {
            return "+" + self.asFormattedNumber()
        } else {
            return self.asFormattedNumber()
        }
    }
    
    // Converts double into percentage representation
    func asPercentage(isChange: Bool) -> String {
        // Convert calling double into NSNumber
        let number = NSNumber(value: self)
        let result = Double.percentageFormatter.string(from: number) ?? "0"
        
        if isChange && self > 0.0 {
            // Append a plus for positive change
            return "+" + result + "%"
        } else {
            return result + "%"
        }
    }
}
