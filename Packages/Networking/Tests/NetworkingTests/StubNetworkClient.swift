import Foundation
import Networking

actor StubNetworkClient: NetworkClient {
    private(set) var requests: [URLRequest] = []
    private var responses: [Result<Data, NetworkError>]

    init(responses: [Result<Data, NetworkError>]) {
        self.responses = responses
    }

    func send(_ request: URLRequest) async throws(NetworkError) -> Data {
        requests.append(request)
        let response = responses.count > 1 ? responses.removeFirst() : responses[0]
        return try response.get()
    }
}

extension NetworkError {
    static let offline = NetworkError.transport(URLError(.notConnectedToInternet))
}
