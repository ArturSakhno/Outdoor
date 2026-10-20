import Foundation
import Networking

struct RemotePlaceRepository: PlaceRepository {
    private enum Constants {
        static let path = "v1/search"
        static let resultCount = 10
        static let cityFeatureCodes: Set<String> = ["PPL", "PPLA", "PPLA2", "PPLA3", "PPLA4", "PPLC", "PPLG"]
    }

    private let baseURL: URL?
    private let networkClient: NetworkClient
    private let languageCode: String

    init(baseURL: URL?, networkClient: NetworkClient, languageCode: String) {
        self.baseURL = baseURL
        self.networkClient = networkClient
        self.languageCode = languageCode
    }

    func searchPlaces(named query: String) async throws(ServiceError) -> [Place] {
        guard let baseURL,
              var components = URLComponents(url: baseURL.appending(path: Constants.path), resolvingAgainstBaseURL: false)
        else { throw .unavailable }
        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "count", value: String(Constants.resultCount)),
            URLQueryItem(name: "language", value: languageCode),
            URLQueryItem(name: "format", value: "json"),
        ]
        guard let url = components.url else { throw .unavailable }
        do {
            let response = try await networkClient.send(URLRequest(url: url), decoding: GeocodingResponseDTO.self)
            return (response.results ?? [])
                .filter { $0.featureCode.map(Constants.cityFeatureCodes.contains) ?? false }
                .map { $0.toDomain() }
        } catch {
            throw error.isOffline ? .offline : .unavailable
        }
    }
}
