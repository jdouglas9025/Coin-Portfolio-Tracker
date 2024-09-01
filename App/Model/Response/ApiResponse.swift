import Foundation

// Represents a generic response from an API endpoint
// Response contains last updated date and typed data that is Codable
struct ApiResponse<T: Codable>: Codable {
    private var id = UUID().uuidString
    
    // May be nil if saved disk data is loaded
    let lastUpdated: String?
    let data: T
    
    // Specific fields to be parsed
    private enum CodingKeys: String, CodingKey {
        case lastUpdated
        case data
    }
}
