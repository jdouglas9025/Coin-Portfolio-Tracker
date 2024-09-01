import Foundation
import SwiftUI
import Combine

// Represents the combined primary/input validation VM for the future value calculator (reverse CAGR) view
class FutureValueViewModel: ObservableObject {
    // Results
    @Published var annualValues: [Double] = []
    @Published var finalValue: String = ""
    
    // Inputs
    @Published var initialAmount: Int?
    @Published var monthlyContribution: Int?
    @Published var numOfYears: Int?
    @Published var growthRate: Double?
    
    @Published var isInitialAmountValid = false
    @Published var isMonthlyContributionValid = false
    @Published var isNumOfYearsValid = false
    @Published var isGrowthRateValid = false
    
    private let initialAmountErrorMessage = "Amount should be > $0 but <= $1 billion"
    private let monthlyContributionErrorMessage = "If provided, amount should be > $0 but <= $1 billion"
    private let numOfYearsErrorMessage = "Years should be > 0 but <= 100"
    private let growthRateErrorMessage = "Rate should be > 0 but <= 500"
    
    var initialAmountPrompt: String {
        if initialAmount == nil || isInitialAmountValid {
            return ""
        } else {
            return initialAmountErrorMessage
        }
    }
    
    var monthlyContributionPrompt: String {
        if monthlyContribution == nil || isMonthlyContributionValid {
            return ""
        } else {
            return monthlyContributionErrorMessage
        }
    }
    
    var numOfYearsPrompt: String {
        if numOfYears == nil || isNumOfYearsValid {
            return ""
        } else {
            return numOfYearsErrorMessage
        }
    }
    
    var growthRatePrompt: String {
        if growthRate == nil || isGrowthRateValid {
            return ""
        } else {
            return growthRateErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        return (isInitialAmountValid && (isMonthlyContributionValid || monthlyContribution == nil) && isNumOfYearsValid && isGrowthRateValid)
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    // Set hard limit of <= 100
    let yearsLimit = 100
    
    // Set hard limit of <= 500
    let growthRateLimit = 500.00
    
    init() {
        setupInputSubscribers()
        setupResultSubscribers()
    }
    
    private func setupInputSubscribers() {
        $initialAmount
            .map { input in
                let input = input ?? 0
                
                return GeneralUtility.amountPredicate.evaluate(with: String(input))
            }
            .assign(to: \.isInitialAmountValid, on: self)
            .store(in: &subscribers)
        
        $monthlyContribution
            .map { input in
                let input = input ?? 0
                
                return GeneralUtility.amountPredicate.evaluate(with: String(input))
            }
            .assign(to: \.isMonthlyContributionValid, on: self)
            .store(in: &subscribers)
        
        $numOfYears
            .map { input in
                let input = input ?? 0
                
                return GeneralUtility.yearsPredicate.evaluate(with: String(input))
                    && (input <= self.yearsLimit)
            }
            .assign(to: \.isNumOfYearsValid, on: self)
            .store(in: &subscribers)

        $growthRate
            .map { input in
                let input = input ?? 0.0
                
                return GeneralUtility.growthRatePredicate.evaluate(with: String(input))
                && (input > 0.0) && (input <= self.growthRateLimit)
            }
            .assign(to: \.isGrowthRateValid, on: self)
            .store(in: &subscribers)
    }
    
    private func setupResultSubscribers() {
        $initialAmount
            .combineLatest($monthlyContribution, $numOfYears, $growthRate)
            .map { (initialAmount, monthlyContribution, numOfYears, growthRate) -> ([Double], String) in
                return self.getValues(initialAmount: initialAmount ?? 0, monthlyContribution: monthlyContribution ?? 0, numOfYears: numOfYears ?? 0, growthRate: growthRate ?? 0.0)
            }
            .sink { [weak self] result in
                self?.annualValues = result.0
                self?.finalValue = result.1
            }
            .store(in: &subscribers)
    }

    private func getValues(initialAmount: Int, monthlyContribution: Int, numOfYears: Int, growthRate: Double) -> ([Double], String) {
        var result: [Double] = []
        
        let initialAmount = Double(initialAmount)
        let monthlyContribution = Double(monthlyContribution)
        let rate = growthRate / 100.0
        
        // Verify valid input
        if initialAmount == 0.0 || rate == 0.0 || numOfYears < 1 {
            return (result, "")
        }
        
        // Year 0 (starting value)
        result.append(initialAmount)
        
        var yearlyValue = initialAmount
        for _ in 1...numOfYears {
            // Multiply previous yearly value by growth rate
            // Add 12 months of contributions on top of this value, then assign to yearly value
            yearlyValue = (yearlyValue * (1.0 + rate)) + (12 * monthlyContribution)
            
            result.append(yearlyValue)
        }
        
        return (result, result[result.count - 1].asCurrency())
    }
}
