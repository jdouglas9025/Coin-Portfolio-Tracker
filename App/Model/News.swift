import Foundation

struct News: Identifiable, Codable {
    var id = UUID().uuidString
    
    let title: String
    // Parsed into correct format using custom decoder in service class
    let publishedDate: Date
    let url: String
    let publisherName: String
    let imageUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case title
        case publishedDate
        case url
        case publisherName
        case imageUrl
    }
}
