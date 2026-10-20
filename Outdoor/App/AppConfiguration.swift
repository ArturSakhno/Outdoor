import Foundation

struct AppConfiguration {
    var geolocationURL = URL(string: "https://geocoding-api.open-meteo.com")
    var weatherURL = URL(string: "https://api.open-meteo.com")
    var requestTimeout: TimeInterval = 15
    var retryDelay: Duration = .seconds(1)
    var searchDebounce: Duration = .milliseconds(300)
    var searchLanguageCode = "en"
}
