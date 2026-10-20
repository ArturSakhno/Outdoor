import Foundation
import Networking
@testable import Outdoor
import Testing

struct RemotePlaceRepositoryTests {
    @Test func keepsTheTownAndDropsTheHeliport() async throws {
        let sut = makeSUT(json: Fixtures.zermattSearch)

        let places = try await sut.searchPlaces(named: "Zermatt")

        #expect(places == [.zermatt])
    }

    @Test func missingResultsMeansNoMatches() async throws {
        let sut = makeSUT(json: Fixtures.noResults)

        let places = try await sut.searchPlaces(named: "xqzvw")

        #expect(places.isEmpty)
    }

    @Test(arguments: [
        ("PPL", true), ("PPLA", true), ("PPLA2", true), ("PPLA3", true), ("PPLA4", true), ("PPLC", true), ("PPLG", true),
        ("PPLX", false), ("PPLL", false), ("PPLH", false), ("PPLQ", false), ("PPLW", false), ("AIRP", false), ("MT", false),
    ])
    func keepsOnlyCitiesAndTowns(featureCode: String, isKept: Bool) async throws {
        let json = #"{"results":[{"id":1,"name":"A","latitude":0,"longitude":0,"feature_code":"\#(featureCode)"}]}"#
        let sut = makeSUT(json: json)

        let places = try await sut.searchPlaces(named: "A")

        #expect(places.isEmpty == !isKept)
    }

    @Test func dropsResultsWithoutAFeatureCode() async throws {
        let sut = makeSUT(json: #"{"results":[{"id":1,"name":"A","latitude":0,"longitude":0}]}"#)

        let places = try await sut.searchPlaces(named: "A")

        #expect(places.isEmpty)
    }

    @Test func sendsTheQueryLanguageAndCount() async throws {
        let client = StubNetworkClient(json: Fixtures.noResults)
        let sut = makeSUT(networkClient: client, languageCode: "pt")

        _ = try await sut.searchPlaces(named: "a b&c")

        let request = try #require(await client.requests.first)
        #expect(request.url?.host() == "geocoding-api.open-meteo.com")
        #expect(request.url?.path() == "/v1/search")
        #expect(request.url?.query(percentEncoded: true) == "name=a%20b%26c&count=10&language=pt&format=json")
    }

    @Test(arguments: [(NetworkError.offline, ServiceError.offline), (.unexpectedStatus(500), .unavailable)])
    func mapsNetworkErrors(error: NetworkError, expected: ServiceError) async {
        let sut = makeSUT(networkClient: StubNetworkClient(responses: [.failure(error)]))

        await #expect(throws: expected) { try await sut.searchPlaces(named: "Zermatt") }
    }
}

private extension RemotePlaceRepositoryTests {
    func makeSUT(json: String) -> RemotePlaceRepository {
        makeSUT(networkClient: StubNetworkClient(json: json))
    }

    func makeSUT(networkClient: NetworkClient, languageCode: String = "en") -> RemotePlaceRepository {
        RemotePlaceRepository(baseURL: AppConfiguration().geolocationURL, networkClient: networkClient, languageCode: languageCode)
    }
}
