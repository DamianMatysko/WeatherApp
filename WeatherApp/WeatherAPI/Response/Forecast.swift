//
//  Forecast.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import Foundation
import SwiftUI

struct Forecast: Codable, Identifiable{
    var id: Int {
        return dt
    }
    
    let dt: Int
    let dt_txt: Date
    let main: Main
    let weather: [Weather]
    
    var weatherMain: String {
        return weather.first?.main ?? ""
    }
    var weatherDescription: String {
        return weather.first?.description ?? ""
    }
    
    var dateFormated:String{
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        return date.formatted()
    }
    
}

struct ForecastResponse: Codable{
    let list: [Forecast]
    
}

extension Forecast{
    /// simple day of forecast
    var day: String {
        self.dt_txt.formatted(.dateTime.day())
    }
    var month: String {
        self.dt_txt.formatted(.dateTime.month(.abbreviated))
    }
    var hour: String {
        self.dt_txt.formatted(.dateTime.hour(.twoDigits(amPM: .narrow)).minute())
    }
}

extension Forecast{
    static func mock() -> Forecast {
        Forecast(dt: 0, dt_txt: Date(), main: Main(temp: 10.5, tempMin: 5, tempMax: 20, humidity: 9), weather: [Weather(main: "Sunny", description: "Clear sky", icon: "1")])
    }
}
