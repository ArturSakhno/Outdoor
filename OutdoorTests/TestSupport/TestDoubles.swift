import ForecastDomain
import Foundation
import Networking
@testable import Outdoor
import Testing

actor StubNetworkClient: NetworkClient {
    private(set) var requests: [URLRequest] = []
    private var responses: [Result<Data, NetworkError>]

    init(responses: [Result<Data, NetworkError>]) {
        self.responses = responses
    }

    init(json: String) {
        self.init(responses: [.success(Data(json.utf8))])
    }

    func send(_ request: URLRequest) async throws(NetworkError) -> Data {
        requests.append(request)
        let response = responses.count > 1 ? responses.removeFirst() : responses[0]
        return try response.get()
    }
}

extension URLRequest {
    var queryValues: [String: String] {
        let items = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?.queryItems ?? []
        return Dictionary(items.map { ($0.name, $0.value ?? "") }, uniquingKeysWith: { first, _ in first })
    }
}

extension NetworkError {
    static let offline = NetworkError.transport(URLError(.notConnectedToInternet))
}

extension Place {
    static let zermatt = Place(
        id: 2_657_928,
        name: "Zermatt",
        region: "Valais",
        country: "Switzerland",
        latitude: 46.01998,
        longitude: 7.74863
    )
}

extension PlaceRowViewData {
    static let zermatt = PlaceRowViewData(id: 2_657_928, name: "Zermatt", subtitle: "Valais, Switzerland")
}

func decodeForecast(_ json: String) throws -> ForecastDTO {
    try JSONDecoder().decode(ForecastDTO.self, from: Data(json.utf8))
}

extension Forecast {
    static func zermatt() throws -> Forecast {
        try #require(try decodeForecast(Fixtures.zermattForecast).toDomain())
    }
}
