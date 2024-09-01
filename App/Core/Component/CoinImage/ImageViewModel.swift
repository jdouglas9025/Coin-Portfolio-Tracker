import Foundation
import SwiftUI
import Combine

class ImageViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let imageService: ImageService
    private var subscribers = Set<AnyCancellable>()
    
    init(uri: String, id: String, storedLocation: ImageService.StoredLocation) {
        // Show progress indicator
        isLoading = true
        // Download image via service
        imageService = ImageService(uri: uri, id: id, storedLocation: storedLocation)
        
        setupImageSub()
    }
    
    private func setupImageSub() {
        imageService.$image
            .sink(receiveCompletion: { _ in
                self.isLoading = false
            }, receiveValue: { [weak self] data in
                self?.image = data
            })
            .store(in: &subscribers)
    }
}
