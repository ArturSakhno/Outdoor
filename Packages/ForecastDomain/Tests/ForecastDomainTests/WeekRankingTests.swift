@testable import ForecastDomain
import Testing

struct WeekRankingTests {
    @Test func bestDaysAreRatingFirstThenTheEarlierDate() {
        let days = ratedDays([.good, .great, .fair, .great, .good])

        let best = WeekRanking.bestDays(in: days)

        #expect(best.map(\.weather.date.day) == [2, 4, 1])
    }

    @Test func poorAndNoDataDaysAreNeverBest() {
        let days = ratedDays([.poor, nil, .fair, .poor])

        let best = WeekRanking.bestDays(in: days)

        #expect(best.map(\.weather.date.day) == [3])
    }

    @Test func noBestDaysInAPoorWeek() {
        #expect(WeekRanking.bestDays(in: ratedDays([.poor, .poor, nil])).isEmpty)
    }

    @Test func outlooksCoverEveryActivityInAFixedOrder() {
        let days = (1...7).map { DailyWeather.sample(date: LocalDate(year: 2026, month: 10, day: $0)) }

        let outlooks = WeekRanking.outlooks(for: Forecast(elevation: 0, days: days))

        #expect(outlooks.map(\.activity) == [.skiing, .surfing, .outdoorSightseeing, .indoorSightseeing])
        #expect(outlooks.allSatisfy { $0.days.count == 7 })
    }
}

private extension WeekRankingTests {
    func ratedDays(_ ratings: [Rating?]) -> [RatedDay] {
        ratings.enumerated().map { index, rating in
            RatedDay(
                weather: .sample(date: LocalDate(year: 2026, month: 10, day: index + 1)),
                rating: rating.map { .rated($0, reasons: []) } ?? .noData
            )
        }
    }
}
