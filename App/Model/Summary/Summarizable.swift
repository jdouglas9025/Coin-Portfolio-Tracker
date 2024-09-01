import Foundation
import SwiftUI

// Type of foreground color (prevents needing to access theme VM in summary model)
enum ForegroundColor {
    case primaryText, positive, unchanged, negative
}

// Protocol for a type that is summarizable and may be used as an item in a summary view
protocol Summarizable {
    var id: String { get set }
    var title: String { get set }
    var foregoundColor: ForegroundColor { get set }
    
    // Returns a formatted string of value according to the specificed implementor's requirements
    func getFormattedValue() -> String
}

