import Foundation

// Extends String type to offer date formatting and HTML description methods
extension String {
    // Converts raw news dates into date objects
    private static var newsDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        
        return formatter
    }
    
    // Sample: "2015-07-30"
    // EX: genesis date
    private static var genesisDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }
    
    // Sample: "2021-11-10T14:24:19.604Z"
    // EX: ATH, ATL dates
    private static var coinDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return formatter
    }
    
    enum DateType {
        case news, genesisDate, coin, lastUpdated
    }
    
    func asDate(dateType: DateType) -> Date {
        guard self != "" else { return Date() }
        
        switch dateType {
            case .news:
                return String.newsDateFormatter.date(from: self) ?? Date()
                
            case .genesisDate:
                return String.genesisDateFormatter.date(from: self) ?? Date()
                
            case .coin:
                return String.coinDateFormatter.date(from: self) ?? Date()
                
            case .lastUpdated:
                return GeneralUtility.lastUpdatedDateFormatter.date(from: self) ?? Date()
        }
    }
    
    // Returns a new string with the custom formatted date representation
    func asFormattedDate(dateType: DateType) -> String {
        // Assert that self is an actual date and not empty string
        guard self != "" else { return "" }
        
        switch dateType {
            case .news:
                return String.newsDateFormatter.date(from: self)?.formatted(date: .numeric, time: .omitted) ?? ""
                
            case .genesisDate:
                return String.genesisDateFormatter.date(from: self)?.formatted(date: .numeric, time: .omitted) ?? ""
                
            case .coin:
                return String.coinDateFormatter.date(from: self)?.formatted(date: .numeric, time: .omitted) ?? ""
                
            case .lastUpdated:
                return GeneralUtility.lastUpdatedDateFormatter.date(from: self)?.formatted(GeneralUtility.shortDateFormatter) ?? ""
        }
    }
    
    // Removes HTML symbols from coin descriptions
    func withoutHtml() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
