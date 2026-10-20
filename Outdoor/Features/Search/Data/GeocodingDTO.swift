import Foundation

struct GeocodingResponseDTO: Decodable {
    let results: [GeocodingResultDTO]?
}

struct GeocodingResultDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case featureCode = "feature_code"
        case admin1
        case country
    }

    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let featureCode: String?
    let admin1: String?
    let country: String?
}

extension GeocodingResultDTO {
    func toDomain() -> Place {
        Place(id: id, name: name, region: admin1, country: country, latitude: latitude, longitude: longitude)
    }
}
