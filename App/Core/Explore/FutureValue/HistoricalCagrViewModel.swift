import Foundation
import SwiftUI
import Combine

// Represents the combined primary/input validation VM for the historical CAGR calculator view
class HistoricalCagrViewModel: ObservableObject {
    // Results
    @Published var historicalCagr: String = ""
    
    // Inputs
    @Published var initialAmount: Int?
    @Published var numOfYears: Int?
    @Published var endAmount: Int?
    
    @Published var isInitialAmountValid = false
    @Published var isNumOfYearsValid = false
    @Published var isEndAmountValid = false
    @Published var isEndAmountGreaterThanInitialAmount = false
    
    private let amountErrorMessage = "Amount should be > $0 but <= $1 billion"
    private let endLessThanInitialErrorMessage = "Final value should be > initial value"
    private let yearsErrorMessage = "Years should be > 0 but <= 100"
    
    var initialAmountPrompt: String {
        if initialAmount == nil || isInitialAmountValid {
            return ""
        } else {
            return amountErrorMessage
        }
    }
    
    var yearsPrompt: String {
        if numOfYears == nil || isNumOfYearsValid {
            return ""
        } else {
            return yearsErrorMessage
        }
    }
    
    var endAmountPrompt: String {
        if endAmount == nil || (isEndAmountValid && isEndAmountGreaterThanInitialAmount) {
            return ""
        } else if isEndAmountValid && !isEndAmountGreaterThanInitialAmount {
            return endLessThanInitialErrorMessage
        } else {
            return amountErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        return (isInitialAmountValid && isNumOfYearsValid && isEndAmountValid && isEndAmountGreaterThanInitialAmount)
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    // Set hard limit of <= 100
    let yearsLimit = 100
    
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
        
        $numOfYears
            .map { input in
                let input = input ?? 0
                
                return GeneralUtility.yearsPredicate.evaluate(with: String(input))
                    && (input <= self.yearsLimit)
            }
            .assign(to: \.isNumOfYearsValid, on: self)
            .store(in: &subscribers)

        $endAmount
            .map { input -> (Bool, Bool) in
                let input = input ?? 0
                
                let isValid = GeneralUtility.amountPredicate.evaluate(with: String(input))
                let isGreaterThanInitialValue = input > self.initialAmount ?? 0
                
                return (isValid, isGreaterThanInitialValue)
            }
            .sink { [weak self] result in
                self?.isEndAmountValid = result.0
                self?.isEndAmountGreaterThanInitialAmount = result.1
            }
            .store(in: &subscribers)
    }

    private func setupResultSubscribers() {
        $initialAmount
            .combineLatest($numOfYears, $endAmount)
            .map { (initialAmount, numOfYears, endAmount) -> String in
                let result = self.getHistoricalCagr(initialAmount: initialAmount ?? 0, numOfYears: numOfYears ?? 0, endAmount: endAmount ?? 0)
                
                return result
            }
            .sink { [weak self] result in
                self?.historicalCagr = result
            }
            .store(in: &subscribers)
    }
    
    private func getHistoricalCagr(initialAmount: Int, numOfYears: Int, endAmount: Int) -> String {
        let initialAmount = Double(initialAmount)
        let numOfYears = Double(numOfYears)
        let endAmount = Double(endAmount)
        
        // Formula for historical CAGR: [(end / start) ^ (1 / N)] - 1
        let result = pow((endAmount / initialAmount), (1.0/numOfYears)) - 1
        
        return (result * 100.0).asPercentage(isChange: false)
    }
}
