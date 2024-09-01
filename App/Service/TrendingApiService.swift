import Foundation
import Combine

class TrendingDataApiService {
    @Published var trendingCoins: [TrendingCoin] = []
    @Published var lastUpdated = ""
    
    private let decoder = JSONDecoder()
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        getTrendingCoins()
    }
    
    // Updates published trending coin data
    func getTrendingCoins() {
        guard let url = URL(string: GeneralUtility.serverBaseUrl + "/api/v1/crypto/trendingData") else { return }
        
        NetworkingManager.download(url: url)
            .decode(type: ApiResponse<[TrendingCoin]>.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                switch status {
                    case .failure:
                        return
                    case .finished:
                        break
                }
            }, receiveValue: { [weak self] container in
                self?.trendingCoins = container.data
                self?.lastUpdated = container.lastUpdated?.asFormattedDate(dateType: .lastUpdated) ?? ""
            })
            .store(in: &subscribers)
    }
}
