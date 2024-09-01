import Foundation
import SwiftUI

// Extension to hide user keyboard upon click on screen outside of touch area
extension UIApplication {
    
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Used for placing banner ads
    func getRootViewController() -> UIViewController {
        guard let screen = self.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
