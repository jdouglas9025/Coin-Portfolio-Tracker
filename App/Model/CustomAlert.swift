import Foundation
import SwiftUI

// Represents the model for a custom alert (warning, error) encountered during runtime
enum CustomAlert: String, CaseIterable {
    case deviceOffline = "Hmm. It looks like your device is offline, which means we're unable to load data from our servers. Try checking your device's internet connection."
    
    case serverOffline = "Hmm. It looks like we're unable to load fresh data from our servers. This may be due to a temporary outage on our end."
    
    case noMatches = "Looks like we aren't able to find any matches. Did you provide the right search term?"
    
    case emptyPortfolio = "Looks like you haven't added any coins yet. Click the slider icon in the top right corner to get started!"
    
    case badData = "Hmm. Looks like there may be an invalid input that is causing some havoc. Double check your values and try again."
    
    case missingData = "Hmm. Looks like there isn't anything to display yet. Have you added some holdings data to your portfolio?"
    
    case none = "Hmm. This was unexpected. Try again in a little bit."
    
    var message: Text {
        return Text(self.rawValue)
    }
    
    var image: Image {
        switch self {
            case .deviceOffline, .serverOffline, .badData, .missingData:
                return Image(systemName: "exclamationmark.triangle")
            
            case .noMatches:
                return Image(systemName: "binoculars")
                
            case .emptyPortfolio:
                return Image(systemName: "figure.wave")
                
            default:
                return Image(systemName: "questionmark")
        }
    }
}
