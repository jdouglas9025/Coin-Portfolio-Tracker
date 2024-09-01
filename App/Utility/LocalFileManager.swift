import Foundation
import SwiftUI

// Accessed via singleton instance
class LocalFileManager {
    static let instance = LocalFileManager()
    
    private init() {}
    
    func saveImage(image: UIImage, imageName: String, folderName: String) {
        // Create necessary folders
        createFolderIfNeeded(folderName: folderName)
        
        // Get path for image
        guard
            // Convert into raw data
            let data = image.pngData(),
            let url = getURLForImage(imageName: imageName, folderName: folderName)
        else { return }
        
        // Save image to path
        do {
            try data.write(to: url)
        } catch {
            // Error saving
            return
        }
    }
    
    func getImage(imageName: String, folderName: String) -> UIImage? {
        guard
            let url = getURLForImage(imageName: imageName, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path) else { return nil }
        
        return UIImage.init(contentsOfFile: url.path)
        
    }
    
    private func createFolderIfNeeded(folderName: String) {
        guard let url = getURLForFolder(folderName: folderName) else { return }
        
        // Check if folder exists
        if !FileManager.default.fileExists(atPath: url.path(percentEncoded: true)) {
            do {
                // Create folder with necessary intermediate directories
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                // Error creating folder
                return
            }
        }
    }
    
    private func getURLForFolder(folderName: String) -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        return url.appendingPathComponent(folderName)
    }
    
    private func getURLForImage(imageName: String, folderName: String) -> URL? {
        guard let folderUrl = getURLForFolder(folderName: folderName) else { return nil }
        
        return folderUrl.appendingPathComponent(imageName + ".png")
    }
}
