//
//  WeatherDetailRow.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import SwiftUI

struct WeatherDetailRow: View {
    let imageSysName: String
    let attribute: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10){
        
                Image(systemName:imageSysName)
                Text(attribute)
                    .foregroundColor(.yellow)
                Spacer()
                Text(value)
                    .foregroundColor(.gray)
            
        }
    }
}

struct WeatherDetailRow_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDetailRow(imageSysName: "sun", attribute: "sunny", value: "23")
    }
    
}
