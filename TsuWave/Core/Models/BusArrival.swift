import Foundation

// MARK: - LTA API Response Models

struct BusArrivalResponse: Codable {
    let busStopCode: String
    let services: [BusService]
    
    enum CodingKeys: String, CodingKey {
        case busStopCode = "BusStopCode"
        case services = "Services"
    }
}

struct BusService: Codable, Identifiable {
    let serviceNo: String
    let operatorCode: String
    let nextBus: BusInfo?
    let nextBus2: BusInfo?
    let nextBus3: BusInfo?
    
    var id: String { serviceNo }
    
    enum CodingKeys: String, CodingKey {
        case serviceNo = "ServiceNo"
        case operatorCode = "Operator"
        case nextBus = "NextBus"
        case nextBus2 = "NextBus2"
        case nextBus3 = "NextBus3"
    }
}

struct BusInfo: Codable {
    let originCode: String
    let destinationCode: String
    let estimatedArrival: Date?
    let latitude: String
    let longitude: String
    let visitNumber: String
    let load: LoadType
    let feature: FeatureType
    let type: BusType
    
    enum CodingKeys: String, CodingKey {
        case originCode = "OriginCode"
        case destinationCode = "DestinationCode"
        case estimatedArrival = "EstimatedArrival"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case visitNumber = "VisitNumber"
        case load = "Load"
        case feature = "Feature"
        case type = "Type"
    }
}

// MARK: - Enums

enum LoadType: String, Codable {
    case seatsAvailable = "SEA"
    case standingAvailable = "SDA"
    case limitedStanding = "LSD"
}

enum FeatureType: String, Codable {
    case wheelchairAccessible = "WAB"
    case none = ""
}

enum BusType: String, Codable {
    case singleDeck = "SD"
    case doubleDeck = "DD"
    case bendy = "BD"
}

// MARK: - App Models

struct MonitoredBus: Identifiable, Codable {
    let id = UUID()
    let busStopCode: String
    let serviceNo: String
    let targetMinutes: Int // Alert when bus is X minutes away
    var isActive: Bool = true
}

struct BusAlert: Identifiable {
    let id = UUID()
    let busStopCode: String
    let serviceNo: String
    let minutesUntilArrival: Int
    let triggeredAt: Date
}
