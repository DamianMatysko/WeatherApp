//
//  Weather.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import Foundation

struct Coord: Codable {
    let lat: Double
    let lon: Double
}

struct WeatherResponse: Codable{
    let weather: [Weather]
    let coord: Coord
    let main: Main
    let name: String
    
    var weatherInfo: String {
        let allWeather = weather.map { element in
            return element.info
        }
        return allWeather.joined(separator: ", ")
    }
}

struct Main: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    
    
    private enum CodingKeys: String, CodingKey{
        case temp = "temp"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity = "humidity"
    }
    
    var tempFormatted: String {
        if #available(iOS 15.0, *){
         return temp.formatted()
        }else{
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 1
            return formatter.string(from: temp as NSNumber) ?? "\(temp)"
        }
    }
}

struct Weather: Codable {
    let main: String
    let description: String
    let icon: String
    
    var info: String {
        return main + "\(description)"
    }
}
