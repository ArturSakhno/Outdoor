import DesignSystem
import ForecastDomain
import Foundation

extension Activity {
    var title: String {
        switch self {
        case .skiing: String(localized: "Skiing")
        case .surfing: String(localized: "Surfing")
        case .outdoorSightseeing: String(localized: "Outdoor sightseeing")
        case .indoorSightseeing: String(localized: "Indoor sightseeing")
        }
    }

    var systemImage: String {
        switch self {
        case .skiing: DS.Icon.skiing
        case .surfing: DS.Icon.surfing
        case .outdoorSightseeing: DS.Icon.walking
        case .indoorSightseeing: DS.Icon.museum
        }
    }

    var note: String? {
        switch self {
        case .surfing: String(localized: "Weather only. Waves are not rated.")
        case .skiing, .outdoorSightseeing, .indoorSightseeing: nil
        }
    }
}

extension DayRating {
    var title: String {
        switch rating {
        case .great: String(localized: "Great")
        case .good: String(localized: "Good")
        case .fair: String(localized: "Fair")
        case .poor: String(localized: "Poor")
        case nil: String(localized: "No data")
        }
    }

    var shortTitle: String {
        rating == nil ? "–" : title
    }

    var tone: RatingTone {
        switch rating {
        case .great: .great
        case .good: .good
        case .fair: .fair
        case .poor: .poor
        case nil: .none
        }
    }
}

extension LocalDate {
    func shortLabel(isFirstDay: Bool, locale: Locale = .current) -> String {
        guard !isFirstDay else { return String(localized: "Today") }
        return formatted(Date.FormatStyle(timeZone: .gmt).weekday(.abbreviated), locale: locale)
    }

    func longLabel(locale: Locale = .current) -> String {
        formatted(Date.FormatStyle(timeZone: .gmt).weekday(.wide).day().month(.wide), locale: locale)
    }
}

private extension LocalDate {
    func formatted(_ style: Date.FormatStyle, locale: Locale) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
        return date.formatted(style.locale(locale))
    }
}

extension Reason {
    var text: String {
        switch self {
        case .thunderstorm: String(localized: "Thunderstorms")
        case let .rain(millimetres, hours): String(localized: "Rain \(millimetres.whole) mm over \(hours.whole) h")
        case let .rainChance(percent): String(localized: "Rain chance \(percent.whole)%")
        case let .feelsCold(celsius): String(localized: "Feels like \(celsius.whole)°, cold")
        case let .feelsHot(celsius): String(localized: "Feels like \(celsius.whole)°, hot")
        case let .wind(speed): String(localized: "Wind \(speed.whole) km/h")
        case let .gusts(speed): String(localized: "Gusts \(speed.whole) km/h")
        case let .littleSun(sunshine, daylight): String(localized: "Sun \(sunshine.whole) of \(daylight.whole) h")
        case let .noSnow(elevation): String(localized: "No snow at \(elevation.whole) m")
        case let .thinSnow(centimetres): String(localized: "Thin snow, \(centimetres.whole) cm")
        case let .warm(celsius): String(localized: "Warm, \(celsius.whole)°: soft snow")
        case let .cold(celsius): String(localized: "Very cold, \(celsius.whole)°")
        case .niceDayOutside: String(localized: "Nice day to be outside")
        case .severeWeather: String(localized: "Severe weather: travel with care")
        }
    }
}

extension Double {
    var whole: String {
        let value = rounded(.toNearestOrEven)
        return (value == 0 ? 0 : value).formatted(.number.precision(.fractionLength(0)))
    }
}
