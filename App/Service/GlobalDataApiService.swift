import Foundation
import Combine

// Service for global data (e.g., total volume, total market cap)
class GlobalDataApiService {
    @Published var globalData: GlobalData?
    @Published var lastUpdated = ""
    
    private let decoder = JSONDecoder()
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        getGlobalData()
    }
    
    // Updates global data (e.g., total volume)
    func getGlobalData() {
        guard let url = URL(string: GeneralUtility.serverBaseUrl + "/api/v1/crypto/globalData") else { return }
        
        NetworkingManager.download(url: url)
            .decode(type: ApiResponse<GlobalData>.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { status in
                switch status {
                    case .failure:
                        return
                    case .finished:
                        break
                }
            }, receiveValue: { [weak self] container in
                self?.globalData = container.data
                self?.lastUpdated = container.lastUpdated?.asFormattedDate(dateType: .lastUpdated) ?? ""
            })
            .store(in: &subscribers)
    }
}
