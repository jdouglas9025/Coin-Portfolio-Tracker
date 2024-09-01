import SwiftUI

// Represents the view to display a news item -- similar to summary view for summary items
struct NewsView: View {
    @EnvironmentObject private var themeVM: ThemeViewModel
    
    let news: News
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            HStack(alignment: .center) {
                if let imageUrl = news.imageUrl {
                    // Retrieve/store in cache (cleared upon app close)
                    ImageView(uri: imageUrl, id: news.id, storedLocation: .cache)
                        .frame(width: 150, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 20.0))
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(news.title)
                .font(.subheadline)
                .foregroundStyle(themeVM.textColorTheme.primaryText)
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 5.0) {
                Text(news.publisherName)
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                
                Text(news.publishedDate.formatted(date: .numeric, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(themeVM.textColorTheme.secondaryText)
                
            }
        }
    }
}
