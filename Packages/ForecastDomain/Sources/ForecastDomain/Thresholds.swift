struct UpperLimits {
    let great: Double
    let good: Double
    let fair: Double

    func rating(for value: Double) -> Rating {
        if value < great { return .great }
        if value < good { return .good }
        if value < fair { return .fair }
        return .poor
    }
}

struct LowerLimits {
    let great: Double
    let good: Double
    let fair: Double

    func rating(for value: Double) -> Rating {
        if value >= great { return .great }
        if value >= good { return .good }
        if value >= fair { return .fair }
        return .poor
    }
}

enum Thresholds {
    static let thunderstormCodes = 95...99

    enum Outdoor {
        static let rain = UpperLimits(great: 1, good: 4, fair: 10)
        static let longRainHours = 12.0
        static let longRainMinimumMillimetres = 1.0
        static let rainChance = UpperLimits(great: 50, good: .infinity, fair: .infinity)
        static let feelsCold = LowerLimits(great: 15, good: 8, fair: 0)
        static let feelsHot = UpperLimits(great: 26, good: 30, fair: 35)
        static let wind = UpperLimits(great: 20, good: 30, fair: 40)
        static let gusts = UpperLimits(great: 40, good: 50, fair: 65)
        static let sunshine = LowerLimits(great: 0.5, good: 0.25, fair: -.infinity)
    }

    enum Surfing {
        static let wind = UpperLimits(great: 15, good: 25, fair: 35)
        static let gusts = UpperLimits(great: 40, good: 50, fair: 60)
        static let feelsLike = LowerLimits(great: 22, good: 16, fair: 10)
        static let rain = UpperLimits(great: 2, good: 10, fair: 20)
    }

    enum Skiing {
        static let snowDepth = LowerLimits(great: 50, good: 30, fair: 5)
        static let warm = UpperLimits(great: 3, good: 8, fair: 15)
        static let cold = LowerLimits(great: -10, good: -20, fair: -.infinity)
        static let gusts = UpperLimits(great: 40, good: 60, fair: 80)
        static let sunshine = LowerLimits(great: 0.4, good: 0.15, fair: -.infinity)
    }

    enum Indoor {
        static let severeGusts = 90.0
    }
}
