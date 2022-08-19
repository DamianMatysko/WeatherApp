//
//  ForecastView.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import SwiftUI

struct ForecastView: View {
    
    let forecast: Forecast
    
    var body: some View {
        
        Section{
            HStack(spacing: 10){
                VStack{
                    Text(forecast.day)
                    Text(forecast.month)
                    Text(forecast.hour)
                }
                VStack(alignment: .center){
                    Text(forecast.weatherMain)
                    Text(forecast.weatherDescription).font(.caption)
                }
                Spacer()
                Text("\(forecast.main.tempFormatted)°C")
            }
        }
    }
}

struct ForecastView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(forecast: Forecast(dt: 0,
                                        dt_txt: Date(),
                                        main: Main(temp: 10, tempMin: 20, tempMax: 26, humidity: 6),
                                        weather: [Weather(main: "sunny", description: "summer day", icon: "1")]))
    }
}
