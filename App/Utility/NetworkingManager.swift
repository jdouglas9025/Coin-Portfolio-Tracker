import Foundation
import SwiftUI
import Combine

// Utility class for making URL requests and handling responses
class NetworkingManager {
    // Downloads data from a remote endpoint
    static func download(url: URL) -> AnyPublisher<Data, Error> {
        // Automatically executes task on background thread
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap {
                // Verify valid HTTP response
                guard let
                        response = $0.response as? HTTPURLResponse, 
                        response.statusCode == 200
                else {
                    throw URLError(.badServerResponse)
                }
                
                return $0.data
            }
            // Retry up to 3 times
            .retry(3)
            .eraseToAnyPublisher()
        
        return publisher
    }
}
