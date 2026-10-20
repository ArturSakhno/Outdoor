import ForecastDomain
import Foundation

struct ForecastDTO: Decodable {
    struct Daily: Decodable {
        fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case apparentTemperatureMax = "apparent_temperature_max"
            case precipitationSum = "precipitation_sum"
            case precipitationHours = "precipitation_hours"
            case precipitationProbabilityMax = "precipitation_probability_max"
            case snowfallSum = "snowfall_sum"
            case snowDepthMax = "snow_depth_max"
            case windSpeedMax = "wind_speed_10m_max"
            case windGustsMax = "wind_gusts_10m_max"
            case sunshineDuration = "sunshine_duration"
            case daylightDuration = "daylight_duration"
        }

        let time: [String]
        let weatherCode: [Int?]
        let temperatureMax: [Double?]
        let temperatureMin: [Double?]
        let apparentTemperatureMax: [Double?]
        let precipitationSum: [Double?]
        let precipitationHours: [Double?]
        let precipitationProbabilityMax: [Double?]
        let snowfallSum: [Double?]
        let snowDepthMax: [Double?]
        let windSpeedMax: [Double?]
        let windGustsMax: [Double?]
        let sunshineDuration: [Double?]
        let daylightDuration: [Double?]
    }

    static let dailyVariables = Daily.CodingKeys.allCases.filter { $0 != .time }.map(\.rawValue)

    let elevation: Double
    let daily: Daily
}

extension ForecastDTO {
    func toDomain() -> Forecast? {
        let count = daily.time.count
        let lengths = [
            daily.weatherCode.count, daily.temperatureMax.count, daily.temperatureMin.count,
            daily.apparentTemperatureMax.count, daily.precipitationSum.count, daily.precipitationHours.count,
            daily.precipitationProbabilityMax.count, daily.snowfallSum.count, daily.snowDepthMax.count,
            daily.windSpeedMax.count, daily.windGustsMax.count, daily.sunshineDuration.count,
            daily.daylightDuration.count,
        ]
        guard lengths.allSatisfy({ $0 == count }) else { return nil }

        var days: [DailyWeather] = []
        for index in 0 ..< count {
            guard let date = LocalDate(iso: daily.time[index]) else { return nil }
            days.append(DailyWeather(
                date: date,
                weatherCode: daily.weatherCode[index],
                temperatureMax: daily.temperatureMax[index],
                temperatureMin: daily.temperatureMin[index],
                apparentTemperatureMax: daily.apparentTemperatureMax[index],
                precipitationSum: daily.precipitationSum[index],
                precipitationHours: daily.precipitationHours[index],
                precipitationProbabilityMax: daily.precipitationProbabilityMax[index],
                snowfallSum: daily.snowfallSum[index],
                snowDepthMax: daily.snowDepthMax[index],
                windSpeedMax: daily.windSpeedMax[index],
                windGustsMax: daily.windGustsMax[index],
                sunshineDuration: daily.sunshineDuration[index],
                daylightDuration: daily.daylightDuration[index]
            ))
        }
        return Forecast(elevation: elevation, days: days)
    }
}
