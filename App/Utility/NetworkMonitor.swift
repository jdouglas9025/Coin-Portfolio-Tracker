import Foundation
import Network

// Utility class for checking if user is connected to the internet
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    
    // Whether the user's device is connected to the internet
    var isOnline = false
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isOnline = (path.status == .satisfied)
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        
        networkMonitor.start(queue: workerQueue)
    }
}
