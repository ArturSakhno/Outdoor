import DesignSystem
import SwiftUI
import Testing

struct ColorTests {
    private enum Constants {
        static let ratings = [DS.Color.ratingGreat, DS.Color.ratingGood, DS.Color.ratingFair, DS.Color.ratingPoor]
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func ratingColorsAreDistinct(in colorScheme: ColorScheme) {
        let resolved = Constants.ratings.map { $0.rgb(in: colorScheme) }

        #expect(Set(resolved).count == Constants.ratings.count)
    }

    @Test func cardSurfaceFollowsColorScheme() {
        #expect(DS.Color.surfaceCard.rgb(in: .light) != DS.Color.surfaceCard.rgb(in: .dark))
    }
}

private extension Color {
    func rgb(in colorScheme: ColorScheme) -> UInt32 {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        let resolved = resolve(in: environment)
        return [resolved.red, resolved.green, resolved.blue]
            .reduce(0) { $0 << 8 | UInt32(($1 * 255).rounded()) }
    }
}
