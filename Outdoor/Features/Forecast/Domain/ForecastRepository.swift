import ForecastDomain

protocol ForecastRepository: Sendable {
    func forecast(latitude: Double, longitude: Double) async throws(ServiceError) -> Forecast
}
