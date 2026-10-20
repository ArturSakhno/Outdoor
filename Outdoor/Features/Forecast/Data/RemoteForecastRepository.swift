import ForecastDomain
import Foundation
import Networking

struct RemoteForecastRepository: ForecastRepository {
    private enum Constants {
        static let path = "v1/forecast"
        static let forecastDays = 7
    }

    private let baseURL: URL?
    private let networkClient: NetworkClient

    init(baseURL: URL?, networkClient: NetworkClient) {
        self.baseURL = baseURL
        self.networkClient = networkClient
    }

    func forecast(latitude: Double, longitude: Double) async throws(ServiceError) -> Forecast {
        guard let baseURL,
              var components = URLComponents(url: baseURL.appending(path: Constants.path), resolvingAgainstBaseURL: false)
        else { throw .unavailable }
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: ForecastDTO.dailyVariables.joined(separator: ",")),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: String(Constants.forecastDays)),
        ]
        guard let url = components.url else { throw .unavailable }
        let dto: ForecastDTO
        do {
            dto = try await networkClient.send(URLRequest(url: url), decoding: ForecastDTO.self)
        } catch {
            throw error.isOffline ? .offline : .unavailable
        }
        guard let forecast = dto.toDomain() else { throw .unavailable }
        return forecast
    }
}
