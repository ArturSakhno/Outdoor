enum ActivityRules {
    private enum Constants {
        static let centimetresPerMetre = 100.0
        static let secondsPerHour = 3600.0
    }

    static func rate(_ activity: Activity, _ day: DailyWeather, elevation: Double) -> DayRating {
        switch activity {
        case .skiing: skiing(day, elevation: elevation)
        case .surfing: surfing(day)
        case .outdoorSightseeing: outdoorSightseeing(day)
        case .indoorSightseeing: indoorSightseeing(day)
        }
    }
}

private struct Factor {
    let rating: Rating
    let reason: Reason
}

private extension ActivityRules {
    static func skiing(_ day: DailyWeather, elevation: Double) -> DayRating {
        guard let code = day.weatherCode,
              let depthMetres = day.snowDepthMax,
              let temperature = day.temperatureMax,
              let gusts = day.windGustsMax,
              let sunshine = day.sunshineDuration,
              let daylight = day.daylightDuration
        else { return .noData }

        let limits = Thresholds.Skiing.self
        let depth = depthMetres * Constants.centimetresPerMetre
        let snowReason: Reason = depth < limits.snowDepth.fair ? .noSnow(elevation: elevation) : .thinSnow(centimetres: depth)
        return combine([
            thunderstorm(code),
            Factor(rating: limits.snowDepth.rating(for: depth), reason: snowReason),
            Factor(rating: limits.warm.rating(for: temperature), reason: .warm(celsius: temperature)),
            Factor(rating: limits.cold.rating(for: temperature), reason: .cold(celsius: temperature)),
            Factor(rating: limits.gusts.rating(for: gusts), reason: .gusts(kilometresPerHour: gusts)),
            sun(sunshine, of: daylight, limits: limits.sunshine),
        ])
    }

    static func surfing(_ day: DailyWeather) -> DayRating {
        guard let code = day.weatherCode,
              let wind = day.windSpeedMax,
              let gusts = day.windGustsMax,
              let feelsLike = day.apparentTemperatureMax,
              let rain = day.precipitationSum,
              let rainHours = day.precipitationHours
        else { return .noData }

        let limits = Thresholds.Surfing.self
        return combine([
            thunderstorm(code),
            Factor(rating: limits.wind.rating(for: wind), reason: .wind(kilometresPerHour: wind)),
            Factor(rating: limits.gusts.rating(for: gusts), reason: .gusts(kilometresPerHour: gusts)),
            Factor(rating: limits.feelsLike.rating(for: feelsLike), reason: .feelsCold(celsius: feelsLike)),
            Factor(rating: limits.rain.rating(for: rain), reason: .rain(millimetres: rain, hours: rainHours)),
        ])
    }

    static func outdoorSightseeing(_ day: DailyWeather) -> DayRating {
        guard let code = day.weatherCode,
              let rain = day.precipitationSum,
              let rainHours = day.precipitationHours,
              let rainChance = day.precipitationProbabilityMax,
              let feelsLike = day.apparentTemperatureMax,
              let wind = day.windSpeedMax,
              let gusts = day.windGustsMax,
              let sunshine = day.sunshineDuration,
              let daylight = day.daylightDuration
        else { return .noData }

        let limits = Thresholds.Outdoor.self
        let isLongRain = rainHours >= limits.longRainHours && rain >= limits.longRainMinimumMillimetres
        let rainRating = min(limits.rain.rating(for: rain), isLongRain ? .fair : .great)
        return combine([
            thunderstorm(code),
            Factor(rating: rainRating, reason: .rain(millimetres: rain, hours: rainHours)),
            Factor(rating: limits.rainChance.rating(for: rainChance), reason: .rainChance(percent: rainChance)),
            Factor(rating: limits.feelsCold.rating(for: feelsLike), reason: .feelsCold(celsius: feelsLike)),
            Factor(rating: limits.feelsHot.rating(for: feelsLike), reason: .feelsHot(celsius: feelsLike)),
            Factor(rating: limits.wind.rating(for: wind), reason: .wind(kilometresPerHour: wind)),
            Factor(rating: limits.gusts.rating(for: gusts), reason: .gusts(kilometresPerHour: gusts)),
            sun(sunshine, of: daylight, limits: limits.sunshine),
        ])
    }

    static func indoorSightseeing(_ day: DailyWeather) -> DayRating {
        guard let outdoor = outdoorSightseeing(day).rating,
              let code = day.weatherCode,
              let gusts = day.windGustsMax
        else { return .noData }

        let isSevere = Thresholds.thunderstormCodes.contains(code) || gusts >= Thresholds.Indoor.severeGusts
        if isSevere {
            return .rated(.fair, reasons: [.severeWeather])
        }
        return outdoor >= .good ? .rated(.good, reasons: [.niceDayOutside]) : .rated(.great, reasons: [])
    }

    static func thunderstorm(_ code: Int) -> Factor {
        Factor(rating: Thresholds.thunderstormCodes.contains(code) ? .poor : .great, reason: .thunderstorm)
    }

    static func sun(_ sunshine: Double, of daylight: Double, limits: LowerLimits) -> Factor {
        let share = daylight > 0 ? sunshine / daylight : 0
        return Factor(
            rating: limits.rating(for: share),
            reason: .littleSun(sunshineHours: sunshine / Constants.secondsPerHour, daylightHours: daylight / Constants.secondsPerHour)
        )
    }

    static func combine(_ factors: [Factor]) -> DayRating {
        let limiting = factors.filter { $0.rating < .great }.sorted { $0.rating < $1.rating }
        return .rated(limiting.first?.rating ?? .great, reasons: limiting.map(\.reason))
    }
}
