import ForecastDomain
import Foundation
import Networking
@testable import Outdoor
import Testing

struct ForecastDTOTests {
    @Test func decodesTheRecordedZermattResponse() throws {
        let forecast = try #require(try decodeForecast(Fixtures.zermattForecast).toDomain())

        #expect(forecast.elevation == 1608)
        #expect(forecast.days.count == 7)
        #expect(forecast.days.first?.date == LocalDate(year: 2026, month: 10, day: 18))
        #expect(forecast.days.last?.date == LocalDate(year: 2026, month: 10, day: 24))
        let first = try #require(forecast.days.first)
        #expect(first.weatherCode == 3)
        #expect(first.apparentTemperatureMax == 8.0)
        #expect(first.precipitationProbabilityMax == 93)
        #expect(first.snowDepthMax == 0)
        #expect(first.windGustsMax == 31.7)
    }

    @Test func keepsNullsAsMissingValues() throws {
        let json = dailyJSON(time: #"["2026-10-18"]"#, gusts: "[null]")

        let forecast = try #require(try decodeForecast(json).toDomain())

        #expect(forecast.days.first?.windGustsMax == nil)
        #expect(forecast.days.first?.windSpeedMax == 10)
    }

    @Test(arguments: [#"["2026-10-18","2026-10-19"]"#, #"["18/10/2026"]"#])
    func rejectsABrokenResponse(time: String) throws {
        #expect(try decodeForecast(dailyJSON(time: time, gusts: "[20]")).toDomain() == nil)
    }

    @Test func requestsSevenDaysInThePlacesTimeZone() async throws {
        let client = StubNetworkClient(json: Fixtures.zermattForecast)

        _ = try await makeSUT(client).forecast(latitude: 46.01998, longitude: 7.74863)

        let request = try #require(await client.requests.first)
        let query = request.queryValues
        #expect(request.url?.host() == "api.open-meteo.com")
        #expect(request.url?.path() == "/v1/forecast")
        #expect(query["latitude"] == "46.01998")
        #expect(query["longitude"] == "7.74863")
        #expect(query["timezone"] == "auto")
        #expect(query["forecast_days"] == "7")
        #expect(query["daily"]?.split(separator: ",").count == 13)
    }

    @Test func repositoryMapsOfflineAndBrokenResponses() async {
        let offline = makeSUT(StubNetworkClient(responses: [.failure(.offline)]))
        let broken = makeSUT(StubNetworkClient(json: #"{"error":true}"#))

        await #expect(throws: ServiceError.offline) { try await offline.forecast(latitude: 0, longitude: 0) }
        await #expect(throws: ServiceError.unavailable) { try await broken.forecast(latitude: 0, longitude: 0) }
    }
}

private extension ForecastDTOTests {
    func makeSUT(_ networkClient: NetworkClient) -> RemoteForecastRepository {
        RemoteForecastRepository(baseURL: AppConfiguration().weatherURL, networkClient: networkClient)
    }

    func dailyJSON(time: String, gusts: String) -> String {
        """
        {"elevation": 10, "daily": {
          "time": \(time), "weather_code": [0], "temperature_2m_max": [20], "temperature_2m_min": [10],
          "apparent_temperature_max": [20], "precipitation_sum": [0], "precipitation_hours": [0],
          "precipitation_probability_max": [0], "snowfall_sum": [0], "snow_depth_max": [0],
          "wind_speed_10m_max": [10], "wind_gusts_10m_max": \(gusts), "sunshine_duration": [30000],
          "daylight_duration": [40000]
        }}
        """
    }
}
