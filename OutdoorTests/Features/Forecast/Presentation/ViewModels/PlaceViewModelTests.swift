import ForecastDomain
@testable import Outdoor
import Testing

@MainActor
struct PlaceViewModelTests {
    @Test func startsLoadingWithTheHeaderFromTheSearchResult() {
        let sut = PlaceViewModel(place: .zermatt, repository: StubForecastRepository(results: [.failure(.unavailable)]))

        #expect(sut.state == .loading)
        #expect(sut.title == "Zermatt")
        #expect(sut.subtitle == "Valais, Switzerland")
    }

    @Test func loadsAndRatesTheWeek() async throws {
        let forecast = try Forecast.zermatt()
        let repository = StubForecastRepository(results: [.success(forecast)])
        let sut = PlaceViewModel(place: .zermatt, repository: repository)

        await sut.load()

        #expect(sut.state == .loaded(.init(elevation: 1608, outlooks: WeekRanking.outlooks(for: forecast))))
        guard case let .loaded(content) = sut.state else { return }
        #expect(content.elevation == "Forecast for \(1608.0.whole) m")
        #expect(content.activities.map(\.title) == ["Skiing", "Surfing", "Outdoor sightseeing", "Indoor sightseeing"])
        #expect(await repository.requestedCoordinates.first == [46.01998, 7.74863])
    }

    @Test(arguments: [(ServiceError.offline, ErrorStatus.offline), (.unavailable, .unavailable)])
    func showsTheError(error: ServiceError, status: ErrorStatus) async {
        let sut = PlaceViewModel(place: .zermatt, repository: StubForecastRepository(results: [.failure(error)]))

        await sut.load()

        #expect(sut.state == .failed(status))
    }

    @Test func retryRecoversAfterAnError() async throws {
        let forecast = try Forecast.zermatt()
        let sut = PlaceViewModel(
            place: .zermatt,
            repository: StubForecastRepository(results: [.failure(.unavailable), .success(forecast)])
        )
        await sut.load()

        sut.retry()

        #expect(sut.state == .loading)
        #expect(sut.retryCount == 1)
        await sut.load()
        #expect(sut.state == .loaded(.init(elevation: 1608, outlooks: WeekRanking.outlooks(for: forecast))))
    }

    @Test func selectingADayOpensItsDetail() async throws {
        let forecast = try Forecast.zermatt()
        let sut = PlaceViewModel(place: .zermatt, repository: StubForecastRepository(results: [.success(forecast)]))
        await sut.load()
        guard case let .loaded(content) = sut.state else {
            Issue.record("Expected loaded, got \(sut.state)")
            return
        }
        let day = try #require(content.activities.first?.days.first)

        sut.select(day)

        #expect(sut.selectedDay == day.detail)
    }

    @Test func aCancelledLoadIsNeverShownAsAnError() async {
        let sut = PlaceViewModel(place: .zermatt, repository: StubForecastRepository(results: [.failure(.unavailable)]))

        let task = Task { await sut.load() }
        task.cancel()
        await task.value

        #expect(sut.state == .loading)
    }
}

private actor StubForecastRepository: ForecastRepository {
    private(set) var requestedCoordinates: [[Double]] = []
    private var results: [Result<Forecast, ServiceError>]

    init(results: [Result<Forecast, ServiceError>]) {
        self.results = results
    }

    func forecast(latitude: Double, longitude: Double) async throws(ServiceError) -> Forecast {
        requestedCoordinates.append([latitude, longitude])
        let result = results.count > 1 ? results.removeFirst() : results[0]
        return try result.get()
    }
}
