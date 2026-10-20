enum Fixtures {
    static let zermattForecast = #"""
    {
      "latitude": 46.015694,
      "longitude": 7.7456336,
      "generationtime_ms": 2.526998519897461,
      "utc_offset_seconds": 7200,
      "timezone": "Europe/Zurich",
      "timezone_abbreviation": "GMT+2",
      "elevation": 1608.0,
      "daily_units": {
        "time": "iso8601",
        "weather_code": "wmo code",
        "temperature_2m_max": "°C",
        "temperature_2m_min": "°C",
        "apparent_temperature_max": "°C",
        "precipitation_sum": "mm",
        "precipitation_hours": "h",
        "precipitation_probability_max": "%",
        "snowfall_sum": "cm",
        "snow_depth_max": "m",
        "wind_speed_10m_max": "km/h",
        "wind_gusts_10m_max": "km/h",
        "sunshine_duration": "s",
        "daylight_duration": "s"
      },
      "daily": {
        "time": ["2026-10-18", "2026-10-19", "2026-10-20", "2026-10-21", "2026-10-22", "2026-10-23", "2026-10-24"],
        "weather_code": [3, 80, 61, 61, 3, 85, 3],
        "temperature_2m_max": [11.6, 14.7, 12.9, 9.8, 9.8, 9.5, 6.6],
        "temperature_2m_min": [5.4, 8.1, 9.1, 3.9, 0.3, 1.9, -0.7],
        "apparent_temperature_max": [8.0, 11.4, 9.7, 7.8, 7.0, 6.2, 2.4],
        "precipitation_sum": [0.0, 1.5, 5.65, 4.1, 0.0, 0.4, 0.6],
        "precipitation_hours": [0.0, 4.0, 18.0, 10.0, 0.0, 3.0, 6.0],
        "precipitation_probability_max": [93, 88, 98, 95, 32, 15, 20],
        "snowfall_sum": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.21],
        "snow_depth_max": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
        "wind_speed_10m_max": [15.6, 18.4, 16.1, 12.2, 9.4, 14.7, 12.4],
        "wind_gusts_10m_max": [31.7, 35.6, 46.4, 35.3, 28.4, 33.8, 26.3],
        "sunshine_duration": [18332.14, 36789.25, 26946.75, 23385.01, 36237.49, 34669.95, 35792.07],
        "daylight_duration": [38899.97, 38711.06, 38522.87, 38335.55, 38149.27, 37964.17, 37780.42]
      }
    }
    """#

    static let zermattSearch = #"""
    {
      "results": [
        {
          "id": 2657928,
          "name": "Zermatt",
          "latitude": 46.01998,
          "longitude": 7.74863,
          "elevation": 1608.0,
          "feature_code": "PPL",
          "country_code": "CH",
          "admin1_id": 2658205,
          "admin2_id": 6458844,
          "admin3_id": 7287631,
          "timezone": "Europe/Zurich",
          "population": 6629,
          "postcodes": [
            "3920"
          ],
          "country_id": 2658434,
          "country": "Switzerland",
          "admin1": "Valais",
          "admin2": "Visp District",
          "admin3": "Zermatt"
        },
        {
          "id": 11862393,
          "name": "Zermatt",
          "latitude": 46.02928,
          "longitude": 7.7533,
          "elevation": 1608.0,
          "feature_code": "AIRH",
          "country_code": "CH",
          "admin1_id": 2658205,
          "admin2_id": 6458844,
          "admin3_id": 7287631,
          "timezone": "Europe/Zurich",
          "country_id": 2658434,
          "country": "Switzerland",
          "admin1": "Valais",
          "admin2": "Visp District",
          "admin3": "Zermatt"
        }
      ],
      "generationtime_ms": 0.10120869
    }
    """#

    static let noResults = #"{"generationtime_ms":0.098347664}"#
}
