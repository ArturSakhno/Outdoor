import SwiftUI

@main
struct OutdoorApp: App {
    private let dependencies = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
