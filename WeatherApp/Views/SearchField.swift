//
//  SearchField.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/11/22.
//

import SwiftUI

struct SearchField: View {
    
    @Binding var searchText: String
    
    var searchAction: (String) -> Void
    var body: some View {
        HStack{
            Image(systemName: "magnifyingglass")
                .padding()
            TextField("e.g. London", text: $searchText)
            Button("Search"){
                searchAction(searchText)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
    }
}

//struct SearchField_Previews: PreviewProvider {
//    static var previews: some View {
//        let kosice: Binding<String> = Binding("Kosice")
//        SearchField(searchText: kosice, searchAction: (String) -> Void)
////        SearchField { searchText in
////
////
////        }
//    }
//}
