//
//  NotificationsView.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/19/22.
//

import SwiftUI

struct NotificationsView: View {
    
    @ObservedObject var notificationsViewModel = NotificationsViewModel()
    @State private var isShowingSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Text("Request permission").onTapGesture {
                    notificationsViewModel.requestPermission()
                }
                Text("Shedule notification").onTapGesture {
                    notificationsViewModel.scheduleNotification()
                }
            }.listStyle(GroupedListStyle())
                .navigationTitle("Title")
                .toolbar {
                    Button {
                        isShowingSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    
                }.sheet(isPresented: $isShowingSheet,
                        onDismiss: didDismiss) {
                    VStack {
                        DatePicker(selection: .constant(Date())/*@END_MENU_TOKEN@*/, label: { /*@START_MENU_TOKEN@*/Text("Date") })
                        Text("License Agreement")
                            .font(.title)
                            .padding(50)
                        Text("""
                                     Terms and conditions go here.
                                 """)
                        .padding(50)
                        Button("Dismiss",
                               action: { isShowingSheet.toggle() })
                    }
                }
            
        }
        
        
    }
}

func didDismiss() {
    // Handle the dismissing action.
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
