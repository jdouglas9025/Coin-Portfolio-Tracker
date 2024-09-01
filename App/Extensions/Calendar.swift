import Foundation

extension Calendar {
    // Calculates the days between two dates, not including start date
    func numberOfDaysBetween(from: Date, to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day ?? 0
    }
}
