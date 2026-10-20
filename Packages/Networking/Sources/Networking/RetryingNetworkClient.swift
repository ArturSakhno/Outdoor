import Foundation

public struct RetryingNetworkClient: NetworkClient {
    private enum Constants {
        static let overloadedStatusCode = 503
    }

    private let wrapped: NetworkClient
    private let delay: Duration

    public init(wrapping wrapped: NetworkClient, delay: Duration) {
        self.wrapped = wrapped
        self.delay = delay
    }

    public func send(_ request: URLRequest) async throws(NetworkError) -> Data {
        do {
            return try await wrapped.send(request)
        } catch {
            guard case .unexpectedStatus(Constants.overloadedStatusCode) = error else { throw error }
            do {
                try await Task.sleep(for: delay)
            } catch {
                throw .transport(CancellationError())
            }
            return try await wrapped.send(request)
        }
    }
}
