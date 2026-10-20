import Foundation
import Networking

@MainActor
struct DependencyContainer {
    private let configuration: AppConfiguration
    private let placeRepository: PlaceRepository
    private let forecastRepository: ForecastRepository

    init(configuration: AppConfiguration = AppConfiguration()) {
        self.configuration = configuration

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = configuration.requestTimeout
        let networkClient = RetryingNetworkClient(
            wrapping: URLSessionNetworkClient(session: URLSession(configuration: sessionConfiguration)),
            delay: configuration.retryDelay
        )

        placeRepository = RemotePlaceRepository(
            baseURL: configuration.geolocationURL,
            networkClient: networkClient,
            languageCode: configuration.searchLanguageCode
        )
        forecastRepository = RemoteForecastRepository(baseURL: configuration.weatherURL, networkClient: networkClient)
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(repository: placeRepository, debounce: configuration.searchDebounce)
    }

    func makePlaceViewModel(for place: Place) -> PlaceViewModel {
        PlaceViewModel(place: place, repository: forecastRepository)
    }
}
