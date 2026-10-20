struct PlaceRowViewData: Equatable, Identifiable {
    let id: Int
    let name: String
    let subtitle: String?
}

extension PlaceRowViewData {
    init(place: Place) {
        self.init(id: place.id, name: place.name, subtitle: place.subtitle)
    }
}
