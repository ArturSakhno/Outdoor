import ForecastDomain
import Foundation

extension ActivityCardViewData {
    init(outlook: ActivityOutlook, locale: Locale) {
        let activity = outlook.activity
        let firstDate = outlook.days.first?.weather.date
        self.init(
            id: "\(activity)",
            title: activity.title,
            systemImage: activity.systemImage,
            bestDays: Self.bestDaysText(outlook.bestDays, firstDate: firstDate, locale: locale),
            note: activity.note,
            days: outlook.days.map { day in
                DayViewData(day: day, activity: activity, isFirstDay: day.weather.date == firstDate, locale: locale)
            }
        )
    }
}

private extension ActivityCardViewData {
    static func bestDaysText(_ bestDays: [RatedDay], firstDate: LocalDate?, locale: Locale) -> String {
        guard !bestDays.isEmpty else { return String(localized: "No good days this week") }
        let labels = bestDays.map { $0.weather.date.shortLabel(isFirstDay: $0.weather.date == firstDate, locale: locale) }
        return String(localized: "Best: \(labels.formatted(.list(type: .and, width: .narrow).locale(locale)))")
    }
}

extension DayViewData {
    init(day: RatedDay, activity: Activity, isFirstDay: Bool, locale: Locale) {
        let date = day.weather.date
        self.init(
            id: date.key,
            label: date.shortLabel(isFirstDay: isFirstDay, locale: locale),
            rating: day.rating.shortTitle,
            tone: day.rating.tone,
            detail: DayDetailViewData(day: day, activity: activity, isFirstDay: isFirstDay, locale: locale)
        )
    }
}

extension DayDetailViewData {
    init(day: RatedDay, activity: Activity, isFirstDay: Bool, locale: Locale) {
        let weather = day.weather
        self.init(
            id: "\(activity)-\(weather.date.key)",
            title: isFirstDay ? String(localized: "Today") : weather.date.longLabel(locale: locale),
            activity: activity.title,
            rating: day.rating.title,
            tone: day.rating.tone,
            reasons: day.rating == .noData
                ? [String(localized: "Some forecast values are missing for this day.")]
                : day.rating.reasons.map(\.text),
            rows: Self.rows(for: weather)
        )
    }
}

private extension DayDetailViewData {
    enum Constants {
        static let centimetresPerMetre = 100.0
        static let secondsPerHour = 3600.0
    }

    static func rows(for weather: DailyWeather) -> [Row] {
        [
            row(String(localized: "Temperature"), temperatureRange(weather.temperatureMin, weather.temperatureMax)),
            row(String(localized: "Feels like, max"), weather.apparentTemperatureMax.map { "\($0.whole)°" }),
            row(String(localized: "Rain"), weather.precipitationSum.map { String(localized: "\($0.whole) mm") }),
            row(String(localized: "Rain hours"), weather.precipitationHours.map { String(localized: "\($0.whole) h") }),
            row(String(localized: "Rain chance"), weather.precipitationProbabilityMax.map { "\($0.whole)%" }),
            row(String(localized: "Wind"), weather.windSpeedMax.map { String(localized: "\($0.whole) km/h") }),
            row(String(localized: "Gusts"), weather.windGustsMax.map { String(localized: "\($0.whole) km/h") }),
            row(String(localized: "Sunshine"), weather.sunshineDuration.map {
                String(localized: "\(($0 / Constants.secondsPerHour).whole) h")
            }),
            row(String(localized: "Snow on the ground"), weather.snowDepthMax.map {
                String(localized: "\(($0 * Constants.centimetresPerMetre).whole) cm")
            }),
            row(String(localized: "Fresh snow"), weather.snowfallSum.map { String(localized: "\($0.whole) cm") }),
        ]
    }

    static func row(_ title: String, _ value: String?) -> Row {
        Row(title: title, value: value ?? "–")
    }

    static func temperatureRange(_ low: Double?, _ high: Double?) -> String? {
        guard let low, let high else { return nil }
        return String(localized: "\(low.whole)° to \(high.whole)°")
    }
}

private extension LocalDate {
    var key: String {
        "\(year)-\(month)-\(day)"
    }
}
