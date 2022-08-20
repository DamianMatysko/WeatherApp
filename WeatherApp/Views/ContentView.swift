//
//  ContentView.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/10/22.
//

import SwiftUI
import Combine

enum Loadable<Response>{
    case notLoaded
    case loaded(Response)
    case failed(Error)
}

struct ContentView: View {
    
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()
    
    var detector = PassthroughSubject<String, Never>()
    
    var seachField: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .padding()
            TextField("e.g. London", text: .constant(""))
            Button("Search"){
            }.padding()
        }
    }
    
    @ViewBuilder
    var currentCity: some View {
        switch viewModel.weather {
        case .notLoaded:
            EmptyView()
        case .loaded(let response):
            Section{
                NavigationLink(destination: WeatherDetailView(viewModel: WeatherDetailViewModel(databaseManager: viewModel.database, weatherResposne: response))){
                    VStack(alignment: .leading){
                        Text(response.name)
                        Text(response.weatherInfo)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
        case .failed(let error):
            Text("Fetching weather failed \(error.localizedDescription)")
        }
        
    }
    
    @ViewBuilder
    var favoritePlaces: some View {
        Section(header: Text("Favorite places")){
            ForEach(viewModel.places){ city in
                Text(city.name ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.setFavoriteToSeachfield(with: city.name)
                    }
                    .swipeActions {
                        Button {
                            print("deleted")
                            viewModel.deleteFavoritePlace(cityName: city.name ?? "")
                            viewModel.fetchPlaces()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                
                        }.tint(.red)

                    }
            }
        }
        
    }
    
    var weatherView: some View {
        NavigationView{
            List{
                Section{
                    SearchField(searchText: $viewModel.fieldText) { city in
                        viewModel.city = city
                    }
                    .onChange(of: viewModel.fieldText){
                        newValue in
                        viewModel.detector.send(newValue)
                    }
                }
                
                currentCity
                favoritePlaces
                
            }.listStyle(GroupedListStyle())
                .navigationTitle("🌈 Weather")
                .onAppear() {
                    viewModel.fetchPlaces()
                    self.viewModel.getLastSearchedCity()
                }
            
        }
        
    }
    
    @ViewBuilder
    var body: some View{
        TabView {
            weatherView
                .tabItem{
                    Label("Weather", systemImage: "cloud.sun")
                }
            
            NotificationsView()
                .tabItem{
                    Label("Notifications", systemImage: "calendar")
                    
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
