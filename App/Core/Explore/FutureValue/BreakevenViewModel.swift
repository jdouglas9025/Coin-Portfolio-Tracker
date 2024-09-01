import Foundation
import SwiftUI
import Combine

// Represents the combined primary/input validation VM for the breakeven calculator view
class BreakevenViewModel: ObservableObject {
    // Results
    @Published var breakevenPoint = ""
    @Published var breakevenChange = ""
    @Published var breakevenChangePercentage = ""
    @Published var numOfYearsUntilBreakeven = ""
    @Published var annualValuesUntilBreakeven: [Double] = []
    
    // Inputs
    @Published var currentValue: Int?
    @Published var costBasis: Int?
    @Published var growthRate: Double?
    
    @Published var isCurrentValueValid = false
    @Published var isCurrentValueLessThanCostBasis = false
    @Published var isCostBasisValid = false
    @Published var isGrowthRateValid = false
    
    private let amountErrorMessage = "Amount should be > $0 but <= $1 billion"
    private let valueGreaterThanCostErrorMessage = "Current value should be < cost basis"
    private let growthRateErrorMessage = "If provided, rate should be > 0 but <= 500"
    
    var currentValuePrompt: String {
        if currentValue == nil || (isCurrentValueValid && isCurrentValueLessThanCostBasis) {
            return ""
        } else if isCurrentValueValid && !isCurrentValueLessThanCostBasis {
            return valueGreaterThanCostErrorMessage
        } else {
            return amountErrorMessage
        }
    }
    
    var costBasisPrompt: String {
        if costBasis == nil || isCostBasisValid {
            return ""
        } else {
            return amountErrorMessage
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
        return (isCurrentValueValid && isCurrentValueLessThanCostBasis && isCostBasisValid) && (growthRate == nil || isGrowthRateValid)
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        setupInputSubscribers()
        setupResultSubscribers()
    }
    
    private func setupInputSubscribers() {
        $currentValue
            .map { input -> (Bool, Bool) in
                let input = input ?? 0
                
                let isValid = GeneralUtility.amountPredicate.evaluate(with: String(input))
                let isLessThanCostBasis = input < self.costBasis ?? 0
                
                return (isValid, isLessThanCostBasis)
            }
            .sink { [weak self] result in
                self?.isCurrentValueValid = result.0
                self?.isCurrentValueLessThanCostBasis = result.1
            }
            .store(in: &subscribers)
        
        $costBasis
            .map { input -> (Bool, Bool) in
                let input = input ?? 0
                
                let isValid = GeneralUtility.amountPredicate.evaluate(with: String(input))
                let isGreaterThanValue = input > self.currentValue ?? 0
                
                return (isValid, isGreaterThanValue)
            }
            .sink { [weak self] result in
                self?.isCostBasisValid = result.0
                self?.isCurrentValueLessThanCostBasis = result.1
            }
            .store(in: &subscribers)

        $growthRate
            .map { input in
                let input = input ?? 0.0
                
                return GeneralUtility.growthRatePredicate.evaluate(with: String(input))
                && (input > 0.0) && (input <= GeneralUtility.growthRateLimit)
            }
            .assign(to: \.isGrowthRateValid, on: self)
            .store(in: &subscribers)
    }
    
    private func setupResultSubscribers() {
        $currentValue
            .combineLatest($costBasis, $growthRate)
            .map { (currentValue, costBasis, growthRate) -> (String, String, String, String, [Double]) in
                let currentValue = currentValue ?? 0
                let costBasis = costBasis ?? 0
                let growthRate = growthRate ?? 0.0
                
                let breakevenPoint = Double(costBasis).asCurrency()
                let breakevenChange = Double(costBasis - currentValue).asFormattedNumber()
                let breakevenChangePercentage = self.getBreakevenChangePercentage(currentValue: currentValue, costBasis: costBasis).asPercentage(isChange: true)
                let numOfYearsUntilBreakeven = self.getNumOfYearsUntilBreakeven(currentValue: currentValue, costBasis: costBasis, growthRate: growthRate).asFormattedNumber()
                let annualValuesUntilBreakeven = self.getAnnualValuesUntilBreakeven(currentValue: currentValue, costBasis: costBasis, growthRate: growthRate)
                
                return (breakevenPoint, breakevenChange, breakevenChangePercentage, numOfYearsUntilBreakeven, annualValuesUntilBreakeven)
            }
            .sink { [weak self] result in
                self?.breakevenPoint = result.0
                self?.breakevenChange = result.1
                self?.breakevenChangePercentage = result.2
                self?.numOfYearsUntilBreakeven = result.3
                self?.annualValuesUntilBreakeven = result.4
            }
            .store(in: &subscribers)
    }
    
    private func getBreakevenChangePercentage(currentValue: Int, costBasis: Int) -> Double {
        let value = Double(currentValue)
        let cost = Double(costBasis)
        
        // Formula for percentage to breakeven: (Cost / Value - 1) * 100
        let result = (cost / value - 1) * 100.0
        
        return result
    }
    
    //TO DO: Refactor below methods into single one; maybe return a tuple?
    private func getNumOfYearsUntilBreakeven(currentValue: Int, costBasis: Int, growthRate: Double) -> Double {
        let value = Double(currentValue)
        let cost = Double(costBasis)
        let rate = growthRate / 100.0
        
        // Formula for getting number of years until breakeven given certain rate: N = log(cost/value) / log(1 + rate)
        let years = log(cost/value) / log(1 + rate)
        
        return years
    }
    
    private func getAnnualValuesUntilBreakeven(currentValue: Int, costBasis: Int, growthRate: Double) -> [Double] {
        let value = Double(currentValue)
        let cost = Double(costBasis)
        let rate = growthRate / 100.0
        
        // Formula for getting number of years until breakeven given certain rate: N = log(cost/value) / log(1 + rate)
        // Get value for ceiling of years (round up) to show at least through breakeven point
        var years = ceil(log(cost/value) / log(1 + rate))
        
        // Verify years is valid number to prevent error
        if (years.isNaN || years.isInfinite) || years < 0 {
            years = 0
        }
        
        var result: [Double] = []
        
        for i in 0...Int(years) {
            // Formula for FV at certain yar based on CAGR
            // FV = PV * (1 + CAGR) ^ N
            let annualValue = value * pow((1.0 + rate), Double(i))
            result.append(annualValue)
        }
        
        return result
    }
}
