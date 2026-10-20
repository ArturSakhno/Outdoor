import Foundation
import Observation

@MainActor
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case results([PlaceRowViewData])
        case empty
        case failed(ErrorStatus)
    }

    struct SearchTrigger: Equatable {
        let query: String
        let retryCount: Int
    }

    private enum Constants {
        static let minimumQueryLength = 2
    }

    var query = ""
    private(set) var state: State = .idle
    @ObservationIgnored var onSelectPlace: (Place) -> Void = { _ in }

    private let repository: PlaceRepository
    private let debounce: Duration
    private var places: [Place] = []
    private var loadedTerm: String?
    private var retryCount = 0

    init(repository: PlaceRepository, debounce: Duration) {
        self.repository = repository
        self.debounce = debounce
    }

    var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var searchTrigger: SearchTrigger {
        SearchTrigger(query: query, retryCount: retryCount)
    }

    func search() async {
        let term = trimmedQuery
        guard term.count >= Constants.minimumQueryLength else {
            loadedTerm = nil
            state = .idle
            return
        }
        guard term != loadedTerm else { return }
        try? await Task.sleep(for: debounce)
        guard !Task.isCancelled else { return }
        await load(term)
    }

    func retry() {
        guard trimmedQuery.count >= Constants.minimumQueryLength else { return }
        state = .loading
        retryCount += 1
    }

    func select(_ row: PlaceRowViewData) {
        guard let place = places.first(where: { $0.id == row.id }) else { return }
        onSelectPlace(place)
    }
}

private extension SearchViewModel {
    func load(_ term: String) async {
        loadedTerm = nil
        if case .results = state {} else {
            state = .loading
        }
        do {
            let found = try await repository.searchPlaces(named: term)
            guard !Task.isCancelled, term == trimmedQuery else { return }
            places = found
            state = found.isEmpty ? .empty : .results(found.map(PlaceRowViewData.init(place:)))
            loadedTerm = term
        } catch {
            guard !Task.isCancelled, term == trimmedQuery else { return }
            places = []
            state = .failed(ErrorStatus(error))
        }
    }
}
