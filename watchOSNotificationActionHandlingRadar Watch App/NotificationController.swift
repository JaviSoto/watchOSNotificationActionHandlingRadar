//
//  NotificationController.swift
//  watchOSNotificationActionHandlingRadar Watch App
//
//  Created by Javier Soto on 9/3/22.
//

import SwiftUI
import UserNotifications

final class NotificationController: WKUserNotificationHostingController<NotificationView> {
    @State
    var notification: UNNotification?
    
    override var body: NotificationView {
        return NotificationView()
    }

    override func didReceive(_ notification: UNNotification) {
        self.notification = notification
    }
}

