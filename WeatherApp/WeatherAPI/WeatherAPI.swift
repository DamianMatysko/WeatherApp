//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import Foundation
import Combine

enum WeatherError: Error{
    case fetchFaild
    case responseError
    case invalidURL
    case invalidParameter
    case objectDecordError
    case generalError(Error)
    case serverError(Int)
}

/// weather api for accesing the weather data on the internet
class WeatherAPI {
    internal init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    let baseURL = "https://api.openweathermap.org/data/2.5"
    let appID = "a4de07cbea5ab68e7f28de9c1ae9a717"
    let weatherEndpoint = "/weather"
    let forecastEndpoint = "/forecast"
    let urlSession: URLSession
    
    func weatherURL(city: String) -> URL? {
        
        if let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            
            let url = baseURL + weatherEndpoint + "?q=" + encodedCity + "&appid=" + appID + "&units=metric"
            return URL(string: url)
        }
        return nil
    }
    
    func forecastURL(city: String) -> URL? {
        if var components = URLComponents(string: baseURL){
            components.path += forecastEndpoint
            components.queryItems = [
                URLQueryItem(name: "q", value: city),
                URLQueryItem(name: "appID", value: appID),
                URLQueryItem(name: "units", value: "metric")
            ]
            return components.url
        }
        return nil
        
    }
    
    
    func fetchWeather(for city: String) -> AnyPublisher<WeatherResponse, WeatherError>{
        guard let url = weatherURL(city: city) else {
            return Fail(outputType: WeatherResponse.self, failure: WeatherError.invalidURL)
                .eraseToAnyPublisher()
            
        }
        
        let request = URLRequest(url: url)
        
        
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({(data: Data, response: URLResponse) in
                guard let urlRespose = response as? HTTPURLResponse, urlRespose.statusCode < 400 else{
                    if let urlRespose = response as? HTTPURLResponse {
                        throw WeatherError.serverError(urlRespose.statusCode)
                    }
                    throw WeatherError.fetchFaild
                }
                return data
            })
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .mapError({ failure in
                WeatherError.fetchFaild
            })
            .eraseToAnyPublisher()
    }
    
    
    /// Featches data for specified city
    /// - Parameter city: City name
    /// - Returns: weather data
    func featchWeatherOLD(for city: String) async throws -> WeatherResponse{
        
        guard let url = weatherURL(city: city) else{
            throw WeatherError.invalidURL
        }
        
        do {
            let request = URLRequest(url: url)
            
            let (data, response) = try await urlSession.data(for: request)
            
            if let urlResposne = response as? HTTPURLResponse, urlResposne.statusCode == 200{
                
                let decoder = JSONDecoder()
                let decorded = try decoder.decode(WeatherResponse.self, from: data)
                
                return decorded
            }
            throw WeatherError.responseError
        } catch let dataError {
            throw WeatherError.generalError(dataError)
        }
        
    }
    
    func fetchForecastTemp(for city: String) -> AnyPublisher<ForecastResponse, WeatherError>{
        guard let url = forecastURL(city: city) else {
            return Fail(outputType: ForecastResponse.self, failure: WeatherError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        
        let decoder = JSONDecoder()
        //        "2022-08-11 15:00:00"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap({(data: Data, response: URLResponse) in
                guard let urlRespose = response as? HTTPURLResponse, urlRespose.statusCode < 400 else{
                    if let urlRespose = response as? HTTPURLResponse {
                        throw WeatherError.serverError(urlRespose.statusCode)
                    }
                    throw WeatherError.fetchFaild
                }
                return data
            })
            .decode(type: ForecastResponse.self, decoder: decoder)
            .mapError({ failure in
                WeatherError.fetchFaild
            })
            .eraseToAnyPublisher()
    }
    
        func fetchForecast(for city: String) async throws -> ForecastResponse {
            guard let url = forecastURL(city: city) else {
                throw WeatherError.invalidURL
            }
            do {
                let request = URLRequest(url: url)
                let (data, response) = try await urlSession.data(for: request)
                //      let responseString = String(data: data, encoding: .utf8)
                if let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 {
                    let decoder = JSONDecoder()
                    //        "2022-08-11 15:00:00"
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    let decoded = try decoder.decode(ForecastResponse.self, from: data)
                    return decoded
                }
                throw WeatherError.responseError
            } catch let dataError {
                throw WeatherError.generalError(dataError)
            }
        }
    
}
