//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/10/22.
//

import SwiftUI
import MapKit

struct CityLocation: Identifiable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    var id: UUID = UUID()
}

struct WeatherDetailView: View {
    
    @ObservedObject var viewModel: WeatherDetailViewModel
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion(center: .init(latitude: 48.71692117035879, longitude: 21.25049061965836), latitudinalMeters: 500, longitudinalMeters: 500)
    
    @State var city: CityLocation = CityLocation(latitude: 48.71692117035879, longitude: 21.25049061965836)
    
        
    var body: some View {
        VStack{
            Map(coordinateRegion: $region,
                annotationItems: [city],
                annotationContent: {
                city in MapPin(coordinate: .init(latitude: city.latitude, longitude: city.longitude))
            }) //_region.projectedValue)
            .frame(height: 200)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            List{
                Section{
                    WeatherDetailRow(imageSysName: "sun.max", attribute: "Temperature", value: String(viewModel.weatherRespose.main.temp)+"°") //TODO: formated
                    WeatherDetailRow(imageSysName: "arrow.down.forward", attribute: "Min Temperature", value: String(viewModel.weatherRespose.main.tempMin)+"°")
                    WeatherDetailRow(imageSysName: "arrow.up.forward", attribute: "Max Temperature", value: String(viewModel.weatherRespose.main.tempMax)+"°")
                    WeatherDetailRow(imageSysName: "drop", attribute: "Humidity", value: String(viewModel.weatherRespose.main.humidity)+"%")
                }
                
                forecastSection
                
            }.listStyle(GroupedListStyle())
                .navigationTitle(viewModel.title)
                .toolbar {
                    Button {
                        self.viewModel.togleFavorite()
                        
                    } label: {
                        Image(systemName: viewModel.favoriteIcon)
                    }
                }.onAppear() {
                    region = MKCoordinateRegion(center: .init(latitude: viewModel.weatherRespose.coord.lat, longitude: viewModel.weatherRespose.coord.lon), latitudinalMeters: 1000, longitudinalMeters: 1000)
                    city = CityLocation(latitude: viewModel.weatherRespose.coord.lon, longitude: viewModel.weatherRespose.coord.lon)
                    self.viewModel.updateIcon()
                    viewModel.fetchForecast()
                }

        }
    }
    
    @ViewBuilder
    var forecastSection: some View {
        switch viewModel.forecast{
        case .notLoaded:
            EmptyView()
        case .loaded(let response):
            Section{
                ForEach(response){ forecast in
                    ForecastView(forecast: forecast)
                }
            }
        case .failed(let error):
            Text("Fetch failed \(error.localizedDescription)")
        }
    }
    
}

struct WeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
                let devices: [String] = [
                    "iPhone SE (3rd generation)",
                    "iPhone 13",
                    "iPad Pro (9.7-inch)"
                ]
        
                ForEach(devices,id: \.self){ deviceName in
                    WeatherDetailView(viewModel: WeatherDetailViewModel(databaseManager: DatabaseManager(), weatherResposne: WeatherResponse(weather: [], coord: Coord(lat: 48, lon: 48), main: Main(temp: 54, tempMin: 54, tempMax: 54, humidity: 34), name: "String")))
                        .previewDevice(PreviewDevice(rawValue: deviceName))
                        .previewDisplayName(deviceName)
                }
        
        
    }
}
