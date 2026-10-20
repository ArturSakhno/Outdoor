@testable import ForecastDomain

extension DailyWeather {
    static func sample(date: LocalDate = LocalDate(year: 2026, month: 10, day: 18)) -> DailyWeather {
        DailyWeather(
            date: date,
            weatherCode: 0,
            temperatureMax: 24,
            temperatureMin: 14,
            apparentTemperatureMax: 24,
            precipitationSum: 0,
            precipitationHours: 0,
            precipitationProbabilityMax: 0,
            snowfallSum: 0,
            snowDepthMax: 1,
            windSpeedMax: 5,
            windGustsMax: 15,
            sunshineDuration: 36000,
            daylightDuration: 40000
        )
    }

    static func sample(for activity: Activity) -> DailyWeather {
        activity == .skiing ? sample().with { $0.temperatureMax = -2 } : sample()
    }

    func with(_ change: (inout DailyWeather) -> Void) -> DailyWeather {
        var copy = self
        change(&copy)
        return copy
    }
}
