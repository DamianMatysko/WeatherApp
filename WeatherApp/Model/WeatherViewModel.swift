//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/15/22.
//

import Foundation
import Combine
import MapKit

class WeatherViewModel: ObservableObject{
    @Published var fieldText = ""
    private let cityKey = "cityKey"
    
    
    internal init(weatherApi: WeatherAPI = WeatherAPI(), database: DatabaseManager = DatabaseManager(), city: String = "") {
        self.api = weatherApi
        self.city = city
        self.database = database
        
        detector
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter({  value in
                value.count > 3
                
            })
            .sink( receiveValue: { recrived in
                self.city = recrived
            })
            .store(in: &cancellable)
    }
    
    var database: DatabaseManager
    var api: WeatherAPI = WeatherAPI()
    
    var detector = PassthroughSubject<String, Never>()
    @Published var places: [City] = []
    
    @Published var weather: Loadable<WeatherResponse> = .notLoaded
    
    var city: String {
        didSet {
            saveLastSearchedCity(with: city)
            fetchWeather()
        }
    }
    
    func getPlaces() -> [City] {
        return database.getData()
    }
    
    func saveLastSearchedCity(with name: String){
        UserDefaults.standard.set(name, forKey: cityKey)
    }
    
    func getLastSearchedCity(){
        fieldText = UserDefaults.standard.string(forKey: cityKey) ?? ""
    }
    
    // MARK: featching headers combine
    var cancellable: Set<AnyCancellable> = []
    
    func fetchWeather(){
        api.fetchWeather(for: city)
        .map({response in
            return Loadable.loaded(response)
        })
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
                self.weather = response
              }
              .store(in: &cancellable)
    }
        
    /// Fetch our data
    func fetch() async {
        Task{
            do {
                let response = try await api.featchWeatherOLD(for: city)
                DispatchQueue.main.async {
                    self.weather = Loadable.loaded(response)
                    //self.database.insert(response.name)
                }

            }catch{
                DispatchQueue.main.async {
                    self.weather = .failed(error)
                }
            }

//            do{
//                let forecastResponse = try await api.fetchForecast(for: city)
//                DispatchQueue.main.async {
//                    let calendar =  Calendar.current
//                    let startOfTheDay = calendar.startOfDay(for: Date())
//                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTheDay)
//                    // 19.8.2022 00:00
//                    forecastResponse.list.filter{ forcast in
//                        forcast.dt_txt < tomorrow!
//                    }
//                    self.forecast = Loadable.loaded(forecastResponse)
//                }
//            }catch{
//                self.forecast = .failed(error)
//            }

        }
    }
    
    func setFavoriteToSeachfield(with favoritePlace: String?) {
        self.fieldText = favoritePlace ?? ""
    }
    
    func fetchPlaces() {
        self.places = database.getData()
    }
    
    func deleteFavoritePlace(cityName: String) {
        database.delete(cityName)
        
    }

}
