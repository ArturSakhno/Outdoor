import Observation
import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    enum Route: Hashable {
        case place(Place)
    }

    var path: [Route] = []

    private let dependencies: DependencyContainer
    private let searchViewModel: SearchViewModel

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        searchViewModel = dependencies.makeSearchViewModel()
        searchViewModel.onSelectPlace = { [weak self] place in
            self?.path.append(.place(place))
        }
    }

    func makeSearchScreen() -> some View {
        SearchScreen(viewModel: searchViewModel)
    }

    @ViewBuilder
    func makeScreen(for route: Route) -> some View {
        switch route {
        case let .place(place):
            PlaceScreen(viewModel: dependencies.makePlaceViewModel(for: place))
        }
    }
}
