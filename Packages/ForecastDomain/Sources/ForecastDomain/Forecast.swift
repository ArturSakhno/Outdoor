public struct LocalDate: Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init?(iso string: String) {
        let parts = string.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(year: parts[0], month: parts[1], day: parts[2])
    }

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public static func < (lhs: LocalDate, rhs: LocalDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

public struct DailyWeather: Equatable, Sendable {
    public let date: LocalDate
    public var weatherCode: Int?
    public var temperatureMax: Double?
    public var temperatureMin: Double?
    public var apparentTemperatureMax: Double?
    public var precipitationSum: Double?
    public var precipitationHours: Double?
    public var precipitationProbabilityMax: Double?
    public var snowfallSum: Double?
    public var snowDepthMax: Double?
    public var windSpeedMax: Double?
    public var windGustsMax: Double?
    public var sunshineDuration: Double?
    public var daylightDuration: Double?

    public init(
        date: LocalDate,
        weatherCode: Int?,
        temperatureMax: Double?,
        temperatureMin: Double?,
        apparentTemperatureMax: Double?,
        precipitationSum: Double?,
        precipitationHours: Double?,
        precipitationProbabilityMax: Double?,
        snowfallSum: Double?,
        snowDepthMax: Double?,
        windSpeedMax: Double?,
        windGustsMax: Double?,
        sunshineDuration: Double?,
        daylightDuration: Double?
    ) {
        self.date = date
        self.weatherCode = weatherCode
        self.temperatureMax = temperatureMax
        self.temperatureMin = temperatureMin
        self.apparentTemperatureMax = apparentTemperatureMax
        self.precipitationSum = precipitationSum
        self.precipitationHours = precipitationHours
        self.precipitationProbabilityMax = precipitationProbabilityMax
        self.snowfallSum = snowfallSum
        self.snowDepthMax = snowDepthMax
        self.windSpeedMax = windSpeedMax
        self.windGustsMax = windGustsMax
        self.sunshineDuration = sunshineDuration
        self.daylightDuration = daylightDuration
    }
}

public struct Forecast: Equatable, Sendable {
    public let elevation: Double
    public let days: [DailyWeather]

    public init(elevation: Double, days: [DailyWeather]) {
        self.elevation = elevation
        self.days = days
    }
}
