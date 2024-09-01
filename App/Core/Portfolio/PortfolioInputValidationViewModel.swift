import Foundation
import Combine

// Input validation VM for portfolio views
class PortfolioInputValidationViewModel: ObservableObject {
    @Published var updatedName = ""
    
    @Published var isUpdatedNameValid = false
    
    private let updatedNameErrorMessage = "Name should be >= 1 but < 20 characters long"
    
    var updatedNamePrompt: String {
        if updatedName.isEmpty || isUpdatedNameValid {
            return ""
        } else {
            return updatedNameErrorMessage
        }
    }
    
    var allValidInputs: Bool {
        return isUpdatedNameValid
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    init(name: String) {
        updatedName = name
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        $updatedName
            .map { input -> Bool in
                let isValid = (input.count >= 1) && (input.count < 20)
        
                return isValid
            }
            .sink { [weak self] result in
                self?.isUpdatedNameValid = result
            }
            .store(in: &subscribers)
    }
}
