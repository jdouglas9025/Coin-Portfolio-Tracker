import SwiftUI

// Represents the view for an image (e.g., coin image, news item image)
struct ImageView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    @StateObject private var imageVM: ImageViewModel
    
    init(uri: String, id: String, storedLocation: ImageService.StoredLocation) {
        // Since we are setting a state object, we use '_'
        _imageVM = StateObject(wrappedValue: ImageViewModel(uri: uri, id: id, storedLocation: storedLocation))
    }
    
    var body: some View {
        ZStack {
            if let image = imageVM.image {
                Image(uiImage: image)
                    .resizable()
                    // Use .fill to force image to fill frame
                    .aspectRatio(contentMode: .fill)
            } else if imageVM.isLoading {
                // Display a dynamic loading icon while image loads
                ProgressView()
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
            } else {
                // Display an error since unable to get image for this coin
                Image(systemName: "questionmark")
                    .font(.headline)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
            }
        }
    }
}
