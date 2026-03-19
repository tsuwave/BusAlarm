import Foundation

enum LTAError: Error {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case noData
}

actor LTABusClient {
    static let shared = LTABusClient()
    
    private let baseURL = "http://datamall2.mytransport.sg/ltaodataservice"
    private let apiKey: String
    private let session: URLSession
    
    private init() {
        // Load from Secrets.xcconfig or Info.plist
        self.apiKey = Bundle.main.infoDictionary?["LTA_API_KEY"] as? String ?? ""
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Bus Arrival
    
    func fetchBusArrival(
        busStopCode: String,
        serviceNo: String? = nil
    ) async throws -> BusArrivalResponse {
        var components = URLComponents(string: "\(baseURL)/BusArrivalv2")!
        
        var queryItems = [URLQueryItem(name: "BusStopCode", value: busStopCode)]
        if let serviceNo = serviceNo {
            queryItems.append(URLQueryItem(name: "ServiceNo", value: serviceNo))
        }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw LTAError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "AccountKey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LTAError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(BusArrivalResponse.self, from: data)
    }
    
    // MARK: - Helper: Minutes Until Arrival
    
    func getMinutesUntilArrival(busInfo: BusInfo?) -> Int? {
        guard let estimatedArrival = busInfo?.estimatedArrival else {
            return nil
        }
        
        let now = Date()
        let interval = estimatedArrival.timeIntervalSince(now)
        return max(0, Int(ceil(interval / 60)))
    }
}
