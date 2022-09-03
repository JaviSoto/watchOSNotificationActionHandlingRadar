//
//  NotificationView.swift
//  watchOSNotificationActionHandlingRadar Watch App
//
//  Created by Javier Soto on 9/3/22.
//

import SwiftUI
import UserNotifications

struct NotificationView: View {
    var notification: UNNotification?
    
    var body: some View {
        Text("Notification")
        
        if let notification = notification {
            VStack {
                Text(notification.request.content.body)
                Text(String(describing: notification.request.content.userInfo))
            }
        }
    }
}
