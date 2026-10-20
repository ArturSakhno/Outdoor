import ForecastDomain
@testable import Outdoor
import Testing

struct RecordedForecastRatingTests {
    @Test func zermattInOctoberHasNoSkiing() throws {
        let forecast = try Forecast.zermatt()

        let skiing = try #require(WeekRanking.outlooks(for: forecast).first { $0.activity == .skiing })

        #expect(skiing.days.count == 7)
        #expect(skiing.days.allSatisfy { $0.rating.reasons.contains(.noSnow(elevation: 1608)) })
        #expect(skiing.bestDays.isEmpty)
    }

    @Test func zermattFirstDayOutdoorIsGoodWithItsReasons() throws {
        let forecast = try Forecast.zermatt()
        let outdoor = try #require(WeekRanking.outlooks(for: forecast).first { $0.activity == .outdoorSightseeing })
        let rating = try #require(outdoor.days.first).rating

        #expect(rating.rating == .good)
        #expect(rating.reasons.count == 3)
        #expect(rating.reasons.first == .rainChance(percent: 93))
    }
}
