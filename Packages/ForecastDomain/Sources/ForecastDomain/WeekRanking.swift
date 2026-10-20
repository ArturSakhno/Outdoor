public enum WeekRanking {
    private enum Constants {
        static let maximumBestDays = 3
    }

    public static func outlooks(for forecast: Forecast) -> [ActivityOutlook] {
        Activity.allCases.map { activity in
            let days = forecast.days.map { day in
                RatedDay(weather: day, rating: ActivityRules.rate(activity, day, elevation: forecast.elevation))
            }
            return ActivityOutlook(activity: activity, days: days, bestDays: bestDays(in: days))
        }
    }

    static func bestDays(in days: [RatedDay]) -> [RatedDay] {
        let candidates = days.filter { day in
            guard let rating = day.rating.rating else { return false }
            return rating >= .fair
        }
        let ranked = candidates.sorted(by: isRankedHigher)
        return Array(ranked.prefix(Constants.maximumBestDays))
    }
}

private extension WeekRanking {
    static func isRankedHigher(_ lhs: RatedDay, than rhs: RatedDay) -> Bool {
        let left = lhs.rating.rating ?? .poor
        let right = rhs.rating.rating ?? .poor
        if left != right {
            return left > right
        }
        return lhs.weather.date < rhs.weather.date
    }
}
