import ForecastDomain
import Foundation
import Observation

@MainActor
@Observable
final class PlaceViewModel {
    enum State: Equatable {
        case loading
        case loaded(Content)
        case failed(ErrorStatus)
    }

    struct Content: Equatable {
        let elevation: String
        let activities: [ActivityCardViewData]
    }

    let title: String
    let subtitle: String?
    private(set) var state: State = .loading
    var selectedDay: DayDetailViewData?
    private(set) var retryCount = 0

    private let place: Place
    private let repository: ForecastRepository

    init(place: Place, repository: ForecastRepository) {
        self.place = place
        self.repository = repository
        title = place.name
        subtitle = place.subtitle
    }

    func load() async {
        do {
            let forecast = try await repository.forecast(latitude: place.latitude, longitude: place.longitude)
            guard !Task.isCancelled else { return }
            state = .loaded(Content(elevation: forecast.elevation, outlooks: WeekRanking.outlooks(for: forecast)))
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed(ErrorStatus(error))
        }
    }

    func retry() {
        state = .loading
        retryCount += 1
    }

    func select(_ day: DayViewData) {
        selectedDay = day.detail
    }
}

extension PlaceViewModel.Content {
    init(elevation: Double, outlooks: [ActivityOutlook], locale: Locale = .current) {
        self.init(
            elevation: String(localized: "Forecast for \(elevation.whole) m"),
            activities: outlooks.map { ActivityCardViewData(outlook: $0, locale: locale) }
        )
    }
}

#if DEBUG
extension PlaceViewModel {
    static func preview() -> PlaceViewModel {
        DependencyContainer().makePlaceViewModel(
            for: Place(
                id: 2_657_928,
                name: "Zermatt",
                region: "Valais",
                country: "Switzerland",
                latitude: 46.02,
                longitude: 7.75
            )
        )
    }
}
#endif
