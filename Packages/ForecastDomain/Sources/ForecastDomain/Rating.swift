public enum Activity: CaseIterable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing
}

public enum Rating: Comparable, Sendable {
    case poor
    case fair
    case good
    case great
}

public enum Reason: Equatable, Sendable {
    case thunderstorm
    case rain(millimetres: Double, hours: Double)
    case rainChance(percent: Double)
    case feelsCold(celsius: Double)
    case feelsHot(celsius: Double)
    case wind(kilometresPerHour: Double)
    case gusts(kilometresPerHour: Double)
    case littleSun(sunshineHours: Double, daylightHours: Double)
    case noSnow(elevation: Double)
    case thinSnow(centimetres: Double)
    case warm(celsius: Double)
    case cold(celsius: Double)
    case niceDayOutside
    case severeWeather
}

public enum DayRating: Equatable, Sendable {
    case rated(Rating, reasons: [Reason])
    case noData

    public var rating: Rating? {
        guard case let .rated(rating, _) = self else { return nil }
        return rating
    }

    public var reasons: [Reason] {
        guard case let .rated(_, reasons) = self else { return [] }
        return reasons
    }
}

public struct RatedDay: Equatable, Sendable {
    public let weather: DailyWeather
    public let rating: DayRating
}

public struct ActivityOutlook: Equatable, Sendable {
    public let activity: Activity
    public let days: [RatedDay]
    public let bestDays: [RatedDay]
}
