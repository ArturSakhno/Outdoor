import SwiftUI

struct RootView: View {
    @State private var coordinator: AppCoordinator

    init(dependencies: DependencyContainer) {
        _coordinator = State(initialValue: AppCoordinator(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.makeSearchScreen()
                .navigationDestination(for: AppCoordinator.Route.self) { route in
                    coordinator.makeScreen(for: route)
                }
        }
    }
}
