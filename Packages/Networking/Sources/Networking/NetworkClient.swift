import Foundation

public protocol NetworkClient: Sendable {
    func send(_ request: URLRequest) async throws(NetworkError) -> Data
}

public extension NetworkClient {
    func send<Response: Decodable>(_ request: URLRequest, decoding _: Response.Type) async throws(NetworkError) -> Response {
        let data = try await send(request)
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw .decoding(error)
        }
    }
}

public struct URLSessionNetworkClient: NetworkClient {
    private enum Constants {
        static let successStatusCode = 200
    }

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws(NetworkError) -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw .transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard httpResponse.statusCode == Constants.successStatusCode else {
            throw .unexpectedStatus(httpResponse.statusCode)
        }
        return data
    }
}
