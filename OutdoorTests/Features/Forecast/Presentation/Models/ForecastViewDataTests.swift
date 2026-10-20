import ForecastDomain
import Foundation
@testable import Outdoor
import Testing

struct ForecastViewDataTests {
    private enum Constants {
        static let british = Locale(identifier: "en_GB")
        static let sunday = LocalDate(year: 2026, month: 10, day: 18)
    }

    @Test func theFirstDayIsTodayOnTheChipAndInTheSheet() throws {
        let card = try card(.outdoorSightseeing, in: .zermatt())
        let first = try #require(card.days.first)

        #expect(card.title == "Outdoor sightseeing")
        #expect(first.label == "Today")
        #expect(first.rating == "Good")
        #expect(first.tone == .good)
        #expect(first.detail.title == "Today")
        #expect(first.detail.activity == "Outdoor sightseeing")
        #expect(first.detail.reasons.first == "Rain chance 93%")
        #expect(card.days[1].label == "Mon")
        #expect(card.days[1].detail.title == "Monday 19 October")
    }

    @Test func theBestDaysAreAList() throws {
        let card = try card(.indoorSightseeing, in: .zermatt())

        #expect(card.bestDays == "Best: Tue, Wed, Thu")
    }

    @Test func aWeekWithoutGoodDaysSaysSo() throws {
        let card = try card(.skiing, in: .zermatt())

        #expect(card.bestDays == "No good days this week")
        #expect(card.note == nil)
        #expect(card.days.allSatisfy { $0.tone == .poor })
    }

    @Test func surfingSaysWhatItDoesNotRate() throws {
        #expect(try card(.surfing, in: .zermatt()).note == "Weather only. Waves are not rated.")
    }

    @Test func aDayWithMissingValuesShowsNoDataAndDashes() throws {
        let forecast = Forecast(elevation: 100, days: [weather()])

        let day = try #require(try card(.outdoorSightseeing, in: forecast).days.first)

        #expect(day.rating == "–")
        #expect(day.tone == .none)
        #expect(day.detail.rating == "No data")
        #expect(day.detail.reasons == ["Some forecast values are missing for this day."])
        #expect(day.detail.rows.allSatisfy { $0.value == "–" })
    }

    @Test func detailRowsConvertUnits() throws {
        var weather = weather()
        weather.temperatureMin = -3.4
        weather.temperatureMax = 2.6
        weather.sunshineDuration = 18000
        weather.snowDepthMax = 0.35
        let forecast = Forecast(elevation: 100, days: [weather])

        let rows = try #require(try card(.skiing, in: forecast).days.first).detail.rows
        let values = Dictionary(uniqueKeysWithValues: rows.map { ($0.title, $0.value) })

        #expect(values["Temperature"] == "-3° to 3°")
        #expect(values["Sunshine"] == "5 h")
        #expect(values["Snow on the ground"] == "35 cm")
        #expect(values["Rain"] == "–")
    }
}

private extension ForecastViewDataTests {
    func card(_ activity: Activity, in forecast: Forecast) throws -> ActivityCardViewData {
        let outlook = try #require(WeekRanking.outlooks(for: forecast).first { $0.activity == activity })
        return ActivityCardViewData(outlook: outlook, locale: Constants.british)
    }

    func weather() -> DailyWeather {
        DailyWeather(
            date: Constants.sunday,
            weatherCode: nil,
            temperatureMax: nil,
            temperatureMin: nil,
            apparentTemperatureMax: nil,
            precipitationSum: nil,
            precipitationHours: nil,
            precipitationProbabilityMax: nil,
            snowfallSum: nil,
            snowDepthMax: nil,
            windSpeedMax: nil,
            windGustsMax: nil,
            sunshineDuration: nil,
            daylightDuration: nil
        )
    }
}
