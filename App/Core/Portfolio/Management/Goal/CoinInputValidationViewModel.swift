import Foundation
import Combine

// Input validation VM for coin views
class CoinInputValidationViewModel: ObservableObject {
    @Published var holdings: Double?
    @Published var costBasis: Int?
    @Published var notes = ""
    
    @Published var isHoldingsValid = false
    @Published var isCostBasisValid = false
    @Published var isNotesValid = false
    
    private let holdingsErrorMessage = "Holdings should be > 0 but < 1 billion"
    private let costBasisErrorMessage = "Amount should be > $0 but <= $1 billion"
    private let notesErrorMessage = "If provided, note should be >= 1 but < 256 characters long"
    
    var holdingsPrompt: String {
        if holdings == nil || isHoldingsValid {
            return ""
        } else {
            return holdingsErrorMessage
        }
    }
    
    var costBasisPrompt: String {
        if costBasis == nil || isCostBasisValid {
            return ""
        } else {
            return costBasisErrorMessage
        }
    }
    
    var notesPrompt: String {
        if notes.isEmpty || isNotesValid {
            return ""
        } else {
            return notesErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        // Allow user to also save a coin with just watchlist status and/or notes -- not required to enter holdings/costBasis
        return (isHoldingsValid && isCostBasisValid && (isNotesValid || notes.isEmpty)) || (holdings == nil && costBasis == nil && (isNotesValid || notes.isEmpty))
        
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    init(holdings: Double?, costBasis: Int?, notes: String) {
        self.holdings = holdings
        self.costBasis = costBasis
        self.notes = notes
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        $holdings
            .map { input -> Bool in
                let input = input ?? 0.0
                
                return GeneralUtility.holdingsPredicate.evaluate(with: String(input)) && input > 0.0
            }
            .sink { [weak self] result in
                self?.isHoldingsValid = result
            }
            .store(in: &subscribers)
        
        $costBasis
            .map { input -> Bool in
                let input = input ?? 0
                
                return GeneralUtility.amountPredicate.evaluate(with: String(input))
            }
            .sink { [weak self] result in
                self?.isCostBasisValid = result
            }
            .store(in: &subscribers)
        
        $notes
            .map { input -> Bool in
                let isValid = (input.count >= 1) && (input.count < 256)
        
                return isValid
            }
            .sink { [weak self] result in
                self?.isNotesValid = result
            }
            .store(in: &subscribers)
    }
}
