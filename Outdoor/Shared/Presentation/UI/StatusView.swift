import DesignSystem
import SwiftUI

struct StatusView: View {
    let error: ErrorStatus
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }

    private var title: LocalizedStringKey {
        switch error {
        case .offline: "No connection"
        case .unavailable: "Something went wrong"
        }
    }

    private var message: LocalizedStringKey {
        switch error {
        case .offline: "Check your internet connection and try again."
        case .unavailable: "The weather service didn't respond. Try again in a moment."
        }
    }

    private var systemImage: String {
        switch error {
        case .offline: DS.Icon.offline
        case .unavailable: DS.Icon.warning
        }
    }
}

#if DEBUG
#Preview {
    StatusView(error: .offline) {}
}
#endif
