import ForecastDomain
import Foundation
@testable import Outdoor
import Testing

struct ForecastFormattingTests {
    private enum Constants {
        static let british = Locale(identifier: "en_GB")
        static let american = Locale(identifier: "en_US")
    }

    @Test func theFirstDayIsTodayTheRestAreWeekdays() {
        let sunday = LocalDate(year: 2026, month: 10, day: 18)

        #expect(sunday.shortLabel(isFirstDay: true) == "Today")
        #expect(sunday.shortLabel(isFirstDay: false, locale: Constants.british) == "Sun")
        #expect(sunday.longLabel(locale: Constants.british) == "Sunday 18 October")
    }

    @Test func weekdaysDoNotShiftWithTheDeviceTimeZone() {
        #expect(LocalDate(year: 2026, month: 10, day: 19).shortLabel(isFirstDay: false, locale: Constants.british) == "Mon")
    }

    @Test func theDateOrderFollowsTheLocale() {
        #expect(LocalDate(year: 2026, month: 10, day: 18).longLabel(locale: Constants.american) == "Sunday, October 18")
    }

    @Test(arguments: [
        (Reason.rain(millimetres: 5.1, hours: 24), "Rain 5 mm over 24 h"),
        (.gusts(kilometresPerHour: 64.6), "Gusts 65 km/h"),
        (.noSnow(elevation: 950), "No snow at 950 m"),
        (.thinSnow(centimetres: 20), "Thin snow, 20 cm"),
        (.littleSun(sunshineHours: 2.2, daylightHours: 10.8), "Sun 2 of 11 h"),
        (.feelsCold(celsius: -3.4), "Feels like -3°, cold"),
    ])
    func reasonText(reason: Reason, expected: String) {
        #expect(reason.text == expected)
    }

    @Test(arguments: [(-0.3, "0"), (-0.5, "0"), (-0.6, "-1"), (2.5, "2")])
    func wholeNumbersNeverShowMinusZero(value: Double, expected: String) {
        #expect(value.whole == expected)
    }

    @Test func noDataHasAWordAndADash() {
        #expect(DayRating.noData.title == "No data")
        #expect(DayRating.noData.shortTitle == "–")
        #expect(DayRating.rated(.fair, reasons: []).shortTitle == "Fair")
    }
}
