@testable import ForecastDomain
import Testing

struct ActivityRulesTests {
    private enum Constants {
        static let outdoorActivities: [Activity] = [.skiing, .surfing, .outdoorSightseeing]
    }

    @Test func theSampleDayIsGreatForEveryActivityButIndoor() {
        #expect(rate(.outdoorSightseeing) == .rated(.great, reasons: []))
        #expect(rate(.surfing) == .rated(.great, reasons: []))
        #expect(rate(.skiing) == .rated(.great, reasons: []))
        #expect(rate(.indoorSightseeing) == .rated(.good, reasons: [.niceDayOutside]))
    }

    @Test(arguments: Constants.outdoorActivities)
    func aThunderstormIsPoorOutside(activity: Activity) {
        #expect(rate(activity) { $0.weatherCode = 95 } == .rated(.poor, reasons: [.thunderstorm]))
    }

    @Test(arguments: Activity.allCases)
    func aMissingValueIsNoDataNeverPoor(activity: Activity) {
        #expect(rate(activity) { $0.windGustsMax = nil } == .noData)
    }

    @Test func aMissingValueAnotherActivityNeedsDoesNotMatter() {
        #expect(rate(.outdoorSightseeing) { $0.snowDepthMax = nil } == .rated(.great, reasons: []))
        #expect(rate(.skiing) { $0.snowDepthMax = nil } == .noData)
    }
}

extension ActivityRulesTests {
    @Test(arguments: [(0.9, Rating.great), (1, .good), (3.9, .good), (4, .fair), (9.9, .fair), (10, .poor)])
    func outdoorRainAmount(millimetres: Double, expected: Rating) {
        let result = rate(.outdoorSightseeing) {
            $0.precipitationSum = millimetres
            $0.precipitationHours = 2
        }
        #expect(result.rating == expected)
    }

    @Test func drizzleAllDayIsFairNotPoor() {
        let result = rate(.outdoorSightseeing) {
            $0.precipitationSum = 5.1
            $0.precipitationHours = 24
        }
        #expect(result == .rated(.fair, reasons: [.rain(millimetres: 5.1, hours: 24)]))
    }

    @Test(arguments: [(11.0, 2.0, Rating.good), (12, 2, .fair), (12, 0.9, .great)])
    func longRainCapsAtFair(hours: Double, millimetres: Double, expected: Rating) {
        let result = rate(.outdoorSightseeing) {
            $0.precipitationSum = millimetres
            $0.precipitationHours = hours
        }
        #expect(result.rating == expected)
    }

    @Test(arguments: [(49.0, Rating.great), (50, .good), (100, .good)])
    func outdoorRainChanceOnlyTakesAwayGreat(percent: Double, expected: Rating) {
        #expect(rate(.outdoorSightseeing) { $0.precipitationProbabilityMax = percent }.rating == expected)
    }

    @Test(arguments: [
        (-0.1, Rating.poor), (0, .fair), (7.9, .fair), (8, .good), (14.9, .good), (15, .great),
        (25.9, .great), (26, .good), (29.9, .good), (30, .fair), (34.9, .fair), (35, .poor),
    ])
    func outdoorFeelsLike(celsius: Double, expected: Rating) {
        #expect(rate(.outdoorSightseeing) { $0.apparentTemperatureMax = celsius }.rating == expected)
    }

    @Test(arguments: [(19.9, Rating.great), (20, .good), (30, .fair), (40, .poor)])
    func outdoorWind(kilometresPerHour: Double, expected: Rating) {
        let result = rate(.outdoorSightseeing) {
            $0.windSpeedMax = kilometresPerHour
            $0.windGustsMax = kilometresPerHour
        }
        #expect(result.rating == expected)
    }

    @Test(arguments: [(39.9, Rating.great), (40, .good), (50, .fair), (64.9, .fair), (65, .poor)])
    func outdoorGusts(kilometresPerHour: Double, expected: Rating) {
        #expect(rate(.outdoorSightseeing) { $0.windGustsMax = kilometresPerHour }.rating == expected)
    }

    @Test(arguments: [(20000.0, Rating.great), (19999, .good), (10000, .good), (9999, .fair), (0, .fair)])
    func outdoorSunshineIsNeverPoor(sunshineSeconds: Double, expected: Rating) {
        let result = rate(.outdoorSightseeing) {
            $0.sunshineDuration = sunshineSeconds
            $0.daylightDuration = 40000
        }
        #expect(result.rating == expected)
    }

    @Test func noDaylightCountsAsNoSun() {
        let result = rate(.outdoorSightseeing) {
            $0.sunshineDuration = 0
            $0.daylightDuration = 0
        }
        #expect(result.rating == .fair)
    }

    @Test func reasonsListTheWorstFactorFirst() {
        let result = rate(.outdoorSightseeing) {
            $0.precipitationProbabilityMax = 80
            $0.windGustsMax = 70
        }
        #expect(result == .rated(.poor, reasons: [.gusts(kilometresPerHour: 70), .rainChance(percent: 80)]))
    }
}

extension ActivityRulesTests {
    @Test(arguments: [(14.9, Rating.great), (15, .good), (25, .fair), (35, .poor)])
    func surfWind(kilometresPerHour: Double, expected: Rating) {
        #expect(rate(.surfing) { $0.windSpeedMax = kilometresPerHour }.rating == expected)
    }

    @Test(arguments: [(39.9, Rating.great), (40, .good), (50, .fair), (60, .poor)])
    func surfGusts(kilometresPerHour: Double, expected: Rating) {
        #expect(rate(.surfing) { $0.windGustsMax = kilometresPerHour }.rating == expected)
    }

    @Test(arguments: [(22.0, Rating.great), (21.9, .good), (16, .good), (15.9, .fair), (10, .fair), (9.9, .poor)])
    func surfFeelsLike(celsius: Double, expected: Rating) {
        #expect(rate(.surfing) { $0.apparentTemperatureMax = celsius }.rating == expected)
    }

    @Test(arguments: [(1.9, Rating.great), (2, .good), (10, .fair), (20, .poor)])
    func surfRain(millimetres: Double, expected: Rating) {
        #expect(rate(.surfing) { $0.precipitationSum = millimetres }.rating == expected)
    }
}

extension ActivityRulesTests {
    @Test(arguments: [(0.5, Rating.great), (0.49, .good), (0.3, .good), (0.29, .fair), (0.05, .fair)])
    func skiSnowDepth(metres: Double, expected: Rating) {
        #expect(rate(.skiing) { $0.snowDepthMax = metres }.rating == expected)
    }

    @Test(arguments: [0.0, 0.01, 0.049])
    func lessThanFiveCentimetresIsNoSnow(metres: Double) {
        #expect(rate(.skiing, elevation: 1608) { $0.snowDepthMax = metres } == .rated(.poor, reasons: [.noSnow(elevation: 1608)]))
    }

    @Test(arguments: [
        (-20.1, Rating.fair), (-20, .good), (-10.1, .good), (-10, .great), (2.9, .great),
        (3, .good), (7.9, .good), (8, .fair), (14.9, .fair), (15, .poor),
    ])
    func skiTemperature(celsius: Double, expected: Rating) {
        #expect(rate(.skiing) { $0.temperatureMax = celsius }.rating == expected)
    }

    @Test(arguments: [(39.9, Rating.great), (40, .good), (60, .fair), (80, .poor)])
    func skiGusts(kilometresPerHour: Double, expected: Rating) {
        #expect(rate(.skiing) { $0.windGustsMax = kilometresPerHour }.rating == expected)
    }

    @Test(arguments: [(16000.0, Rating.great), (15999, .good), (6000, .good), (5999, .fair)])
    func skiSunshineAsVisibility(sunshineSeconds: Double, expected: Rating) {
        let result = rate(.skiing) {
            $0.sunshineDuration = sunshineSeconds
            $0.daylightDuration = 40000
        }
        #expect(result.rating == expected)
    }
}

extension ActivityRulesTests {
    @Test func aBadDayOutsideIsGreatInside() {
        let badDay: (inout DailyWeather) -> Void = {
            $0.precipitationSum = 12
            $0.precipitationHours = 8
        }

        #expect(rate(.outdoorSightseeing, changing: badDay).rating == .poor)
        #expect(rate(.indoorSightseeing, changing: badDay) == .rated(.great, reasons: []))
    }

    @Test func aFairDayOutsideIsGreatInside() {
        #expect(rate(.indoorSightseeing) { $0.apparentTemperatureMax = 5 } == .rated(.great, reasons: []))
    }

    @Test(arguments: [95, 99])
    func thunderstormsCapIndoorAtFair(code: Int) {
        #expect(rate(.indoorSightseeing) { $0.weatherCode = code } == .rated(.fair, reasons: [.severeWeather]))
    }

    @Test(arguments: [(89.9, Rating.great), (90, .fair)])
    func damagingGustsCapIndoorAtFair(kilometresPerHour: Double, expected: Rating) {
        #expect(rate(.indoorSightseeing) { $0.windGustsMax = kilometresPerHour }.rating == expected)
    }
}

extension ActivityRulesTests {
    @Test(arguments: Constants.outdoorActivities)
    func moreRainNeverHelps(activity: Activity) {
        expectNonIncreasing(activity, over: stride(from: 0, through: 40, by: 0.5)) { day, value in
            day.precipitationSum = value
            day.precipitationHours = min(24, value * 2)
        }
    }

    @Test(arguments: Constants.outdoorActivities)
    func strongerWindNeverHelps(activity: Activity) {
        expectNonIncreasing(activity, over: stride(from: 0, through: 120, by: 1)) { day, value in
            day.windSpeedMax = value
            day.windGustsMax = value * 1.5
        }
    }

    @Test(arguments: Constants.outdoorActivities)
    func lessSunNeverHelps(activity: Activity) {
        expectNonIncreasing(activity, over: stride(from: 40000, through: 0, by: -500)) { day, value in
            day.sunshineDuration = value
        }
    }
}

private extension ActivityRulesTests {
    func rate(
        _ activity: Activity,
        elevation: Double = 1000,
        changing change: (inout DailyWeather) -> Void = { _ in }
    ) -> DayRating {
        ActivityRules.rate(activity, DailyWeather.sample(for: activity).with(change), elevation: elevation)
    }

    func expectNonIncreasing(
        _ activity: Activity,
        over values: some Sequence<Double>,
        sourceLocation: SourceLocation = #_sourceLocation,
        change: (inout DailyWeather, Double) -> Void
    ) {
        var previous = Rating.great
        for value in values {
            guard let rating = rate(activity, changing: { change(&$0, value) }).rating else {
                Issue.record("No data at \(value)", sourceLocation: sourceLocation)
                return
            }
            #expect(rating <= previous, "rating rose at \(value)", sourceLocation: sourceLocation)
            previous = rating
        }
    }
}
