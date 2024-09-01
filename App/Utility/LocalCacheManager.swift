import Foundation
import SwiftUI

// Used for saving/retrieving images from a local cache -- cache is cleared upon app close
// Used for temporary images such as article thumbnails that do not need to persist beyond a session
class LocalCacheManager {
    static let instance = LocalCacheManager()
    private init() {}
    
    private var imageCache: NSCache<NSString, UIImage> {
        let cache = NSCache<NSString, UIImage>()
        
        // Store up to 150 images since up to 150 articles in single load
        cache.countLimit = 150
        
        return cache
    }
    
    func saveImage(image: UIImage, name: String) {
        imageCache.setObject(image, forKey: name as NSString)
    }
    
    func getImage(name: String) -> UIImage? {
        return imageCache.object(forKey: name as NSString)
    }
}
