import Foundation

public enum NetworkError: Error, Sendable {
    private enum Constants {
        static let offlineCodes: Set<URLError.Code> = [
            .notConnectedToInternet,
            .networkConnectionLost,
            .dataNotAllowed,
            .internationalRoamingOff,
        ]
    }

    case transport(any Error)
    case invalidResponse
    case unexpectedStatus(Int)
    case decoding(any Error)

    public var isOffline: Bool {
        guard case let .transport(error) = self, let urlError = error as? URLError else { return false }
        return Constants.offlineCodes.contains(urlError.code)
    }
}
