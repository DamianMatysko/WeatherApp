//
//  ContentView.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/10/22.
//

import SwiftUI

enum Loadable<Response>{
    case notLoaded
    case loaded(Response)
    case failed(Error)
}

struct ContentView: View {
    
    @StateObject var viewModel: WeatherViewModel = WeatherViewModel()

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
            }
        }
        
    }
    
    @ViewBuilder
    var body: some View{
        NavigationView{
            List{
                Section{
                    SearchField(searchText: $viewModel.fieldText) { city in
                        viewModel.city = city
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
