import Foundation
import Combine

class NewsFeedApiService {
    @Published var newsFeed: [News] = []
    @Published var lastUpdated = ""
    
    private let decoder: JSONDecoder
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        // Setup decoder with custom date parsing logic
        // Parse dates when data is received rather than at subscriber level -- prevents performance bottleneck
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(GeneralUtility.newsDateFormatter)
        
        getNews()
    }
    
    // Updates news data
    func getNews() {
        guard let url = URL(string: GeneralUtility.serverBaseUrl + "/api/v1/crypto/newsData") else { return }
        
        NetworkingManager.download(url: url)
            .decode(type: ApiResponse<[News]>.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                switch status {
                    case .failure:
                        return
                    case .finished:
                        break
                }
            }, receiveValue: { [weak self] container in
                self?.newsFeed = container.data
                self?.lastUpdated = container.lastUpdated?.asFormattedDate(dateType: .lastUpdated) ?? ""
            })
            .store(in: &subscribers)
    }
}
