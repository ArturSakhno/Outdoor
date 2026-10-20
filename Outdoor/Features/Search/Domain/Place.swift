struct Place: Hashable, Identifiable {
    let id: Int
    let name: String
    let region: String?
    let country: String?
    let latitude: Double
    let longitude: Double
}
