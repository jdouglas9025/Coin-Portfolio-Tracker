import Foundation
import SwiftUI
import Combine

// Represents the combined primary/input validation VM for the capital gains calculator view
class CapitalGainsViewModel: ObservableObject {
    // Results
    @Published var capitalGain = 0.0
    @Published var netInvestmentIncomeTax = 0.0
    
    @Published var shortTermFederalCapitalGainTax = 0.0
    @Published var shortTermTotalCapitalGainTax = 0.0
    @Published var shortTermTotalCapitalGainTaxEffectiveRate = 0.0
    @Published var shortTermTotalAmountAfterTax = 0.0
    
    @Published var longTermFederalCapitalGainTax = 0.0
    @Published var longTermTotalCapitalGainTax = 0.0
    @Published var longTermTotalCapitalGainTaxEffectiveRate = 0.0
    @Published var longTermTotalAmountAfterTax = 0.0
    
    // Savings for short-term vs. long-term holding
    @Published var totalCapitalGainTaxSavings = 0.0
    // Data for bar chart
    @Published var chartData: [CapitalGain] = []
    
    // Inputs
    @Published var costBasis: Int?
    @Published var saleValue: Int?
    @Published var yearlyIncome: Int?
    
    @Published var isCostBasisValid = false
    @Published var isCostBasisLessThanSaleValue = false
    @Published var isSaleValueValid = false
    @Published var isYearlyIncomeValid = false
    
    private let amountErrorMessage = "Amount should be > $0 but <= $1 billion"
    private let costLessThanSaleErrorMessage = "Cost basis should be < sale value"
    private let yearlyIncomeErrorMessage = "Amount should be >= $0 but <= $1 billion"
    
    var costBasisPrompt: String {
        if costBasis == nil || (isCostBasisValid && isCostBasisLessThanSaleValue) {
            return ""
        } else if isCostBasisValid && !isCostBasisLessThanSaleValue {
            return costLessThanSaleErrorMessage
        } else {
            return amountErrorMessage
        }
    }
    
    var saleValuePrompt: String {
        if saleValue == nil || isSaleValueValid {
            return ""
        } else {
            return amountErrorMessage
        }
    }
    
    var yearlyIncomePrompt: String {
        if yearlyIncome == nil || isYearlyIncomeValid {
            return ""
        } else {
            return yearlyIncomeErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        return (isCostBasisValid && isCostBasisLessThanSaleValue && isSaleValueValid && isYearlyIncomeValid)
    }
    
    private var subscribers = Set<AnyCancellable>()

    // Min is 0 and max is 1 billion
    private var yearlyIncomePredicate: NSPredicate {
        NSPredicate(format: "SELF MATCHES %@", "^[0-9][0-9]{0,9}$")
    }
    
    init() {
        setupInputSubscribers()
        setupResultSubscribers()
    }
    
    private func setupInputSubscribers() {
        $costBasis
            .map { input -> (Bool, Bool) in
                let input = input ?? 0
                
                let isValid = GeneralUtility.amountPredicate.evaluate(with: String(input))
                let isLessThanSaleValue = input < self.saleValue ?? 0
                
                return (isValid, isLessThanSaleValue)
            }
            .sink { [weak self] result in
                self?.isCostBasisValid = result.0
                self?.isCostBasisLessThanSaleValue = result.1
            }
            .store(in: &subscribers)
        
        $saleValue
            .map { input -> (Bool, Bool) in
                let input = input ?? 0
                
                let isValid = GeneralUtility.amountPredicate.evaluate(with: String(input))
                let isGreaterThanCostBasis = input > self.costBasis ?? 0
                
                return (isValid, isGreaterThanCostBasis)
            }
            .sink { [weak self] result in
                self?.isSaleValueValid = result.0
                self?.isCostBasisLessThanSaleValue = result.1
            }
            .store(in: &subscribers)

        $yearlyIncome
            .map { input -> Bool in
                let input = input ?? 0
                
                let isValid = self.yearlyIncomePredicate.evaluate(with: String(input))
                
                return isValid
            }
            .sink { [weak self] result in
                self?.isYearlyIncomeValid = result
            }
            .store(in: &subscribers)
    }
    
    private func setupResultSubscribers() {
        $costBasis
            .combineLatest($saleValue, $yearlyIncome)
            .map { (costBasis, saleValue, yearlyIncome) -> (Double, Double, [CapitalGain]) in
                let cost = Double(costBasis ?? 0)
                let sale = Double(saleValue ?? 0)
                let income = Double(yearlyIncome ?? 0)
                
                let capitalGain = sale - cost
                
                self.updateNetInvestmentIncomeTax(costBasis: cost, saleValue: sale, otherIncome: income)
                
                self.updateShortTermTaxes(costBasis: cost, saleValue: sale, otherIncome: income)
                self.updateLongTermTaxes(costBasis: cost, saleValue: sale, otherIncome: income)
                
                // Update chart data once all calculations computed
                let chartData = [
                    CapitalGain(taxSystem: .shortTerm, taxType: .federal, total: self.shortTermFederalCapitalGainTax),
                    CapitalGain(taxSystem: .shortTerm, taxType: .NIIT, total: self.netInvestmentIncomeTax),
                    CapitalGain(taxSystem: .longTerm, taxType: .federal, total: self.longTermFederalCapitalGainTax),
                    CapitalGain(taxSystem: .longTerm, taxType: .NIIT, total: self.netInvestmentIncomeTax)
                ]
                
                let federalCapitalGainTaxSavings = self.shortTermFederalCapitalGainTax - self.longTermFederalCapitalGainTax
                
                return (capitalGain, federalCapitalGainTaxSavings, chartData)
            }
            .sink { [weak self] result in
                self?.capitalGain = result.0
                self?.totalCapitalGainTaxSavings = result.1
                self?.chartData = result.2
            }
            .store(in: &subscribers)
    }
    
    private func updateShortTermTaxes(costBasis: Double, saleValue: Double, otherIncome: Double) {
        // Tax brackets for 2024 tax year -- short-term -- single filer with standard deduction included
        // Standard deduction for 2024 is $14,600 for single filer
        
        // 0% for first $14,600 (standard deduction)
        // 10% for next $11,600
        // 12% for next $35,550
        // 22% for next $53,375
        // 24% for next $91,425
        // 32% for next $51,775
        // 35% for next $365,625
        // 37% afterwards
        let topRate = 0.37
        
        let taxBrackets = [
            (0.00, 14_600.0),
            (0.10, 11_600.0),
            (0.12, 35_550.0),
            (0.22, 53_375.0),
            (0.24, 91_425.0),
            (0.32, 51_775.0),
            (0.35, 365_625.0)
        ]
        
        // Determing starting bracket for gains based on other income
        var startingBracket = 0
        var remainingBracketAmount = taxBrackets[startingBracket].1
        
        var otherIncome = otherIncome
        while (otherIncome > 0.0 && startingBracket < taxBrackets.count) {
            if otherIncome > taxBrackets[startingBracket].1 {
                otherIncome -= taxBrackets[startingBracket].1
                startingBracket += 1
            } else {
                // Bracket is bigger than remaining income, so start from here after taking out income
                remainingBracketAmount = taxBrackets[startingBracket].1 - otherIncome
                otherIncome = 0.0
            }
        }
        
        var capitalGain = saleValue - costBasis
        var totalCapitalGainTax = 0.0
        
        if capitalGain <= remainingBracketAmount {
            // Gain is less than remaining amount, so tax gain at bracket rate
            totalCapitalGainTax += (capitalGain * taxBrackets[startingBracket].0)
            capitalGain = 0.0
        } else {
            // Add remaining bracket amount * rate to total tax
            totalCapitalGainTax += (remainingBracketAmount * taxBrackets[startingBracket].0)
            
            // Decrease remaining gain by amount that was just taxed
            capitalGain -= remainingBracketAmount
            
            remainingBracketAmount = 0.0
            // Increase starting bracket for remaining amount
            startingBracket += 1
        }
        
        while (capitalGain > 0.0 && startingBracket < taxBrackets.count) {
            if capitalGain > taxBrackets[startingBracket].1 {
                let bracketAmount = taxBrackets[startingBracket].1
                let tax = taxBrackets[startingBracket].1 * taxBrackets[startingBracket].0
                
                // Add total bracket tax
                totalCapitalGainTax += tax
                
                // Decrease remaining gain by amount that was just taxed
                capitalGain -= bracketAmount
                // Increase starting bracket for remaining capital gain
                startingBracket += 1
            } else {
                // Bracket is >= than remaining capital gain
                totalCapitalGainTax += (capitalGain * taxBrackets[startingBracket].0)
                capitalGain = 0.0
            }
        }
               
        // Tax any remaining gain at maxRate if all brackets exceeded
        totalCapitalGainTax += (capitalGain * topRate)
        
        shortTermFederalCapitalGainTax = totalCapitalGainTax
        
        // Include NIIT in total calculations
        shortTermTotalCapitalGainTax = shortTermFederalCapitalGainTax + netInvestmentIncomeTax
        shortTermTotalCapitalGainTaxEffectiveRate = (shortTermTotalCapitalGainTax / (saleValue - costBasis)) * 100.0
        shortTermTotalAmountAfterTax = saleValue - shortTermTotalCapitalGainTax
    }
    
    private func updateLongTermTaxes(costBasis: Double, saleValue: Double, otherIncome: Double) {
        // Tax brackets for 2024 tax year -- long-term -- single filer with standard deduction included
        // Standard deduction for 2024 is $14,600 for single filer
        
        // 0% for first $14,600 (standard deduction)
        // 0% for next $47,025
        // 15% for next $471,875
        // 20% afterwards
        let topRate = 0.20
        
        let taxBrackets = [
            (0.00, 14_600.0),
            (0.00, 47_025.0),
            (0.15, 471_875.0)
        ]
        
        // Determing starting bracket for gains based on other income
        var startingBracket = 0
        var remainingBracketAmount = taxBrackets[startingBracket].1
        
        var otherIncome = otherIncome
        while (otherIncome > 0.0 && startingBracket < taxBrackets.count) {
            if otherIncome > taxBrackets[startingBracket].1 {
                otherIncome -= taxBrackets[startingBracket].1
                startingBracket += 1
            } else {
                // Bracket is bigger than remaining income, so start from here after taking out income
                remainingBracketAmount = taxBrackets[startingBracket].1 - otherIncome
                otherIncome = 0.0
            }
        }
        
        var capitalGain = saleValue - costBasis
        var totalCapitalGainTax = 0.0
        
        if capitalGain <= remainingBracketAmount {
            // Gain is less than remaining amount, so tax gain at bracket rate
            totalCapitalGainTax += (capitalGain * taxBrackets[startingBracket].0)
            capitalGain = 0.0
        } else {
            // Add remaining bracket amount * rate to total tax
            totalCapitalGainTax += (remainingBracketAmount * taxBrackets[startingBracket].0)
            
            // Decrease remaining gain by amount that was just taxed
            capitalGain -= remainingBracketAmount
            
            remainingBracketAmount = 0.0
            // Increase starting bracket for remaining amount
            startingBracket += 1
        }
        
        while (capitalGain > 0.0 && startingBracket < taxBrackets.count) {
            if capitalGain > taxBrackets[startingBracket].1 {
                let bracketAmount = taxBrackets[startingBracket].1
                let tax = taxBrackets[startingBracket].1 * taxBrackets[startingBracket].0
            
                // Add total bracket tax
                totalCapitalGainTax += tax
                
                // Decrease remaining gain by amount that was just taxed
                capitalGain -= bracketAmount
                // Increase starting bracket for remaining capital gain
                startingBracket += 1
            } else {
                // Bracket is >= than remaining capital gain
                totalCapitalGainTax += (capitalGain * taxBrackets[startingBracket].0)
                capitalGain = 0.0
            }
        }
               
        // Tax any remaining gain at maxRate if all brackets exceeded
        totalCapitalGainTax += (capitalGain * topRate)
    
        longTermFederalCapitalGainTax = totalCapitalGainTax
        
        // Include NIIT in total calculations
        longTermTotalCapitalGainTax = longTermFederalCapitalGainTax + netInvestmentIncomeTax
        longTermTotalCapitalGainTaxEffectiveRate = (longTermTotalCapitalGainTax / (saleValue - costBasis)) * 100.0
        longTermTotalAmountAfterTax = saleValue - longTermTotalCapitalGainTax
    }
    
    // Calculates the NIIT (if any) based on capital gains and other income
    private func updateNetInvestmentIncomeTax(costBasis: Double, saleValue: Double, otherIncome: Double) {
        // For 2024, NIIT applies to income over $200,000 -- single filer
        // Standard deduction for 2024 is $14,600 for single filer
        
        // For 2024, NIIT is 3.8%
        let taxRate = 0.038
        // Total income threshold which NIIT applies to above and beyond is $14,600 (standard deduction) + $200,000
        let threshold = 214_600.0
        
        let capitalGain = saleValue - costBasis
        let totalIncome = capitalGain + otherIncome
        
        let difference = totalIncome - threshold
        
        if difference <= 0.0 {
            // NIIT doesn't apply
            netInvestmentIncomeTax = 0.0
        } else {
            // NIIT applies (apply to income above threshold)
            netInvestmentIncomeTax = difference * taxRate
        }
    }
}
