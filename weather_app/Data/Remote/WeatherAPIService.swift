// Data/Remote/WeatherAPIService.swift
// WeatherCast App
// Alamofire + Combine networking layer

import Foundation
import Alamofire
import Combine

final class WeatherAPIService {

    // MARK: - Constants

    private enum Constants {
        static let apiKey      = AppSecrets.weatherAPIKey   // ← loaded from Configuration/AppSecrets.swift
        static let baseURL     = "https://api.weatherapi.com/v1"
        static let forecastURL = "\(baseURL)/forecast.json"
        static let searchURL   = "\(baseURL)/search.json"
    }

    // MARK: - Shared Alamofire Session

    private let session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest  = 15
        configuration.timeoutIntervalForResource = 30
        return Session(configuration: configuration)
    }()

    // MARK: - Fetch Full Weather + Forecast

    /// Fetches weather + 3-day forecast for a given query string (city name, "lat,lon", etc.)
    func fetchWeather(query: String) -> AnyPublisher<WeatherResponseDTO, Error> {
        let parameters: Parameters = [
            "key":  Constants.apiKey,
            "q":    query,
            "days": 3,
            "aqi":  "yes",
            "alerts": "no"
        ]

        return Future<WeatherResponseDTO, Error> { [weak self] promise in
            guard let self else { return }
            self.session
                .request(Constants.forecastURL, parameters: parameters)
                .validate()
                .responseDecodable(of: WeatherResponseDTO.self) { response in
                    switch response.result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - City Search

    /// Searches for matching city names — used to populate the search bar results.
    func searchCities(query: String) -> AnyPublisher<[CitySearchResultDTO], Error> {
        let parameters: Parameters = [
            "key": Constants.apiKey,
            "q":   query
        ]

        return Future<[CitySearchResultDTO], Error> { [weak self] promise in
            guard let self else { return }
            self.session
                .request(Constants.searchURL, parameters: parameters)
                .validate()
                .responseDecodable(of: [CitySearchResultDTO].self) { response in
                    switch response.result {
                    case .success(let dtos):
                        promise(.success(dtos))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
