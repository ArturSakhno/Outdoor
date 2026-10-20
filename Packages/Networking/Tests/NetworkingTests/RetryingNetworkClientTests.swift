import Foundation
import Networking
import Testing

struct RetryingNetworkClientTests {
    private let request = URLRequest(url: URL(fileURLWithPath: "/"))
    private let body = Data("ok".utf8)

    @Test func retriesOnceAfterServiceOverloaded() async throws {
        let wrapped = StubNetworkClient(responses: [.failure(.unexpectedStatus(503)), .success(body)])
        let sut = RetryingNetworkClient(wrapping: wrapped, delay: .zero)

        let data = try await sut.send(request)

        #expect(data == body)
        #expect(await wrapped.requests.count == 2)
    }

    @Test func givesUpAfterTheSecondOverloadedResponse() async {
        let wrapped = StubNetworkClient(responses: [.failure(.unexpectedStatus(503))])
        let sut = RetryingNetworkClient(wrapping: wrapped, delay: .zero)

        await #expect(throws: NetworkError.self) { try await sut.send(request) }
        #expect(await wrapped.requests.count == 2)
    }

    @Test(arguments: [NetworkError.unexpectedStatus(400), .unexpectedStatus(404), .unexpectedStatus(500), .offline])
    func doesNotRetryOtherFailures(error: NetworkError) async {
        let wrapped = StubNetworkClient(responses: [.failure(error), .success(body)])
        let sut = RetryingNetworkClient(wrapping: wrapped, delay: .zero)

        await #expect(throws: NetworkError.self) { try await sut.send(request) }
        #expect(await wrapped.requests.count == 1)
    }
}

struct NetworkErrorTests {
    @Test(arguments: [URLError.Code.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed])
    func connectionErrorsCountAsOffline(code: URLError.Code) {
        #expect(NetworkError.transport(URLError(code)).isOffline)
    }

    @Test func otherErrorsAreNotOffline() {
        #expect(!NetworkError.transport(URLError(.timedOut)).isOffline)
        #expect(!NetworkError.unexpectedStatus(503).isOffline)
    }
}
