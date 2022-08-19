//
//  WeatherDetailViewModel.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/16/22.
//

import Foundation
import Combine
import MapKit
import SwiftUI

class WeatherDetailViewModel: ObservableObject {
    let databaseManager: DatabaseManager
    @Published var favoriteIcon: String = "heart"
    var weatherRespose: WeatherResponse
    @Published var forecast: Loadable<[Forecast]> = .notLoaded
    var api: WeatherAPI
    
    init(weatherApi: WeatherAPI = WeatherAPI(),databaseManager: DatabaseManager, weatherResposne: WeatherResponse){
        
        self.api = weatherApi
        self.databaseManager = databaseManager
        self.weatherRespose = weatherResposne
        
    }
    
    var title: String {
        "Weather for \(weatherRespose.name)"
    }
    
    func isCityFavorite() -> Bool {
        let records = databaseManager.getData(by: weatherRespose.name)
        return records.count > 0
    }
    
    func togleFavorite(){
        let isFavorite = isCityFavorite()
        if isFavorite {
            unFavoriteCity()
        }else{
            favoriteCity()
        }
    }
    
    func updateIcon(){
        let isFavorite = isCityFavorite()
        favoriteIcon = isFavorite ? "heart.fill" : "heart"
    }
    
    func unFavoriteCity(){
        databaseManager.delete(weatherRespose.name)
        updateIcon()
    }
    
    func favoriteCity() {
        databaseManager.insert(weatherRespose.name)
        updateIcon()
    }
    
    // MARK: featching headers combine
    var cancellable: Set<AnyCancellable> = []
    
    func processResponse(response: ForecastResponse){
        let calendar =  Calendar.current
        let startOfTheDay = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTheDay)
        let fiveDays = calendar.date(byAdding: .day, value: 5, to: startOfTheDay)
        // 19.8.2022 00:00
        
        let elevenHours = calendar.date(
                  bySettingHour: 11,
                  minute: 00,
                  second: 0,
                  of: fiveDays!)

        let newForcast = response.list.filter { forcast in
           // forcast.dt_txt < tomorrow!
            forcast.dt_txt < fiveDays!
        }
    
        newForcast.forEach{ forecast in
         //   if forecast.dt_txt.time
          //  listOfFinalForecast.(forecast)
        }
        //TODO: swipe na row navigation bar
        self.forecast = Loadable.loaded(newForcast)
    }
    
    
    func fetchForecast(){
        api.fetchForecastTemp(for: weatherRespose.name)
        //        .map({response in
        //            return Loadable.loaded(response)
        //        })
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("We have data!")
                case .failure(let weatherError):
                    print("Something went wrong: \(weatherError.localizedDescription)")
                }
            } receiveValue: { response in
                self.processResponse(response: response)
                self.forecast = self.forecast
            }
            .store(in: &cancellable)
    }
    
    func deleteFavoritePlace(cityName: String) {
        
        
    }
    
}
