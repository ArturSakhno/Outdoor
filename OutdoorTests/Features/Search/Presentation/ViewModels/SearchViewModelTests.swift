@testable import Outdoor
import Testing

@MainActor
struct SearchViewModelTests {
    @Test(arguments: ["", "L", "  L  "])
    func staysIdleBelowTwoCharacters(query: String) async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = query

        await sut.search()

        #expect(sut.state == .idle)
        #expect(await repository.searchedTerms.isEmpty)
    }

    @Test func showsResultsForTheTrimmedQuery() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "  Zermatt "

        await sut.search()

        #expect(sut.state == .results([.zermatt]))
        #expect(await repository.searchedTerms == ["Zermatt"])
    }

    @Test func showsEmptyWhenNothingMatches() async {
        let sut = SearchViewModel(repository: StubPlaceRepository(result: .success([])), debounce: .zero)
        sut.query = "xqzvw"

        await sut.search()

        #expect(sut.state == .empty)
    }

    @Test(arguments: [(ServiceError.offline, ErrorStatus.offline), (.unavailable, .unavailable)])
    func showsTheError(error: ServiceError, status: ErrorStatus) async {
        let sut = SearchViewModel(repository: StubPlaceRepository(result: .failure(error)), debounce: .zero)
        sut.query = "Zermatt"

        await sut.search()

        #expect(sut.state == .failed(status))
    }

    @Test func selectingARowHandsOnItsPlace() async {
        let sut = SearchViewModel(repository: StubPlaceRepository(result: .success([.zermatt])), debounce: .zero)
        var selected: [Place] = []
        sut.onSelectPlace = { selected.append($0) }
        sut.query = "Zermatt"
        await sut.search()

        sut.select(.zermatt)

        #expect(selected == [.zermatt])
    }

    @Test func retryRunsTheCurrentQueryAgain() async {
        let repository = StubPlaceRepository(results: [.failure(.unavailable), .success([.zermatt])])
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "Zermatt"
        await sut.search()
        let failedTrigger = sut.searchTrigger

        sut.retry()

        #expect(sut.state == .loading)
        #expect(sut.searchTrigger != failedTrigger)
        await sut.search()
        #expect(sut.state == .results([.zermatt]))
        #expect(await repository.searchedTerms == ["Zermatt", "Zermatt"])
    }

    @Test func retryIgnoresAQueryThatIsTooShort() async {
        let sut = SearchViewModel(repository: StubPlaceRepository(result: .failure(.offline)), debounce: .zero)
        sut.query = "L"
        let trigger = sut.searchTrigger

        sut.retry()

        #expect(sut.searchTrigger == trigger)
        #expect(sut.state == .idle)
    }

    @Test func keepsTheResultsWhenTheSameQueryIsSearchedAgain() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "Zermatt"
        await sut.search()

        await sut.search()

        #expect(sut.state == .results([.zermatt]))
        #expect(await repository.searchedTerms == ["Zermatt"])
    }

    @Test func searchesAgainAfterTheQueryWasCleared() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "Zermatt"
        await sut.search()
        sut.query = ""
        await sut.search()
        sut.query = "Zermatt"

        await sut.search()

        #expect(sut.state == .results([.zermatt]))
        #expect(await repository.searchedTerms == ["Zermatt", "Zermatt"])
    }

    @Test func searchesAgainAfterAFailure() async {
        let repository = StubPlaceRepository(results: [.failure(.offline), .success([.zermatt])])
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "Zermatt"
        await sut.search()

        await sut.search()

        #expect(sut.state == .results([.zermatt]))
    }

    @Test func anOlderResponseNeverReplacesANewerQuery() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        await repository.setOnSearch { _ in sut.query = "London" }
        sut.query = "Lon"

        await sut.search()

        #expect(sut.state == .loading)
    }

    @Test func keepsThePreviousResultsWhileTheNextQueryLoads() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .zero)
        sut.query = "Zer"
        await sut.search()
        let stateDuringSearch = StateRecorder()
        await repository.setOnSearch { _ in stateDuringSearch.state = sut.state }
        sut.query = "Zermatt"

        await sut.search()

        #expect(stateDuringSearch.state == .results([.zermatt]))
    }

    @Test func aSearchCancelledDuringTheDebounceNeverReachesTheRepository() async {
        let repository = StubPlaceRepository(result: .success([.zermatt]))
        let sut = SearchViewModel(repository: repository, debounce: .seconds(60))
        sut.query = "Zermatt"

        let task = Task { await sut.search() }
        task.cancel()
        await task.value

        #expect(await repository.searchedTerms.isEmpty)
        #expect(sut.state == .idle)
    }
}

@MainActor
private final class StateRecorder {
    var state: SearchViewModel.State?
}

private actor StubPlaceRepository: PlaceRepository {
    private(set) var searchedTerms: [String] = []
    private var results: [Result<[Place], ServiceError>]
    private var onSearch: @MainActor @Sendable (String) -> Void = { _ in }

    init(results: [Result<[Place], ServiceError>]) {
        self.results = results
    }

    init(result: Result<[Place], ServiceError>) {
        self.init(results: [result])
    }

    func setOnSearch(_ onSearch: @escaping @MainActor @Sendable (String) -> Void) {
        self.onSearch = onSearch
    }

    func searchPlaces(named query: String) async throws(ServiceError) -> [Place] {
        searchedTerms.append(query)
        await onSearch(query)
        let result = results.count > 1 ? results.removeFirst() : results[0]
        return try result.get()
    }
}
