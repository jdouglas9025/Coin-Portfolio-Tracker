import Foundation
import Combine

// Input validation VM for goal views
class GoalInputValidationViewModel: ObservableObject {
    @Published var description: String
    @Published var targetAmount: Int?
    
    @Published var isDescriptionValid = false
    @Published var isTargetAmountValid = false
    
    private let descriptionErrorMessage = "Description should be > 0 but <= 50 characters long"
    private let targetAmountErrorMessage = "Amount should be > $0 but <= $1 billion"
    
    var descriptionPrompt: String {
        if description.isEmpty || isDescriptionValid {
            return ""
        } else {
            return descriptionErrorMessage
        }
    }
    
    var targetAmountPrompt: String {
        if targetAmount == nil || isTargetAmountValid {
            return ""
        } else {
            return targetAmountErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        return isDescriptionValid && isTargetAmountValid
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    init(description: String, targetAmount: Int?) {
        self.description = description
        self.targetAmount = targetAmount
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        $description
            .map { input -> Bool in
                let isValid = (input.count > 0) && (input.count <= 50)
        
                return isValid
            }
            .sink { [weak self] result in
                self?.isDescriptionValid = result
            }
            .store(in: &subscribers)
        
        $targetAmount
            .map { input -> Bool in
                let input = input ?? 0
                
                return GeneralUtility.amountPredicate.evaluate(with: String(input))
            }
            .sink { [weak self] result in
                self?.isTargetAmountValid = result
            }
            .store(in: &subscribers)
    }
}
