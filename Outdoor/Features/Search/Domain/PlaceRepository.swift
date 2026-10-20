protocol PlaceRepository: Sendable {
    func searchPlaces(named query: String) async throws(ServiceError) -> [Place]
}
