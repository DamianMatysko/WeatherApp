//
//  NotificationsViewModel.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/19/22.
//

import Foundation
import Combine
import UserNotifications

class NotificationsViewModel: ObservableObject {
    
    func requestPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("“All set!“")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "My first notification"
        content.subtitle = "“And its content :)”"
        content.sound = UNNotificationSound.default
        //    UNCalendarNotificationTrigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
