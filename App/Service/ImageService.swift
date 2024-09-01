import Foundation
import SwiftUI
import Combine

// Utility service class used to retrieve images from the file manager/cache or internet as well as save them accordingly
class ImageService {
    @Published var image: UIImage?
    
    private var subscribers = Set<AnyCancellable>()
    
    private let uri: String
    private let imageName: String
    
    private let localFileManager = LocalFileManager.instance
    private let folderName = "coinportfoliotracker-app-images"
    private let localCacheManager = LocalCacheManager.instance
    
    // Image's stored location (file manager for coin images; cache for news images)
    enum StoredLocation {
        case fileManager, cache
    }
    
    private let storedLocation: StoredLocation
    
    // Takes in the URI of the image as well as the item's id (for saving/lookup) and where the image should be stored
    init(uri: String, id: String, storedLocation: StoredLocation) {
        self.uri = uri
        imageName = id
        self.storedLocation = storedLocation
        
        getImage()
    }
    
    // Retrieves the image; if the image is saved to the file system/cache, it will load from there
    // Else, it will call downloadImage() to retrieve and save the image from the internet
    private func getImage() {
        switch storedLocation {
            case .fileManager:
                if let image = localFileManager.getImage(imageName: imageName, folderName: folderName) {
                    self.image = image
                } else {
                    downloadImage()
                }
            case .cache:
                if let image = localCacheManager.getImage(name: imageName) {
                    self.image = image
                } else {
                    downloadImage()
                }
        }
    }
    
    // Download the current image from the internet and save it to the file system/cache
    private func downloadImage() {
        guard let url = URL(string: uri) else { return }
        
        NetworkingManager.download(url: url)
            .tryMap({ data -> UIImage? in
                return UIImage(data: data)
            })
            // Switch from background thread to main thread
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                switch status {
                    case .failure:
                        return
                    case .finished:
                        break
                }
            }, receiveValue: { [weak self] data in
                guard
                    let self = self,
                    let data = data
                else { return }
                
                self.image = data
                
                // Save image
                switch storedLocation {
                    case .fileManager:
                        self.localFileManager.saveImage(image: data, imageName: imageName, folderName: folderName)
                    case .cache:
                        self.localCacheManager.saveImage(image: data, name: imageName)
                }
            })
            // Since this may be a large number of requests, need to store in subs.
            .store(in: &subscribers)
    }
}
