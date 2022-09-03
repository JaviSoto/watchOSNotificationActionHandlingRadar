//
//  watchOSNotificationActionHandlingRadarApp.swift
//  watchOSNotificationActionHandlingRadar Watch App
//
//  Created by Javier Soto on 9/3/22.
//

import SwiftUI
import UserNotifications

private func path(from notificationResponse: UNNotificationResponse) -> NavigationPath {
    let identifierFromPayload = (notificationResponse.notification.request.content.userInfo["custom_payload_identifier"] as? String).flatMap(Int.init)
    
    return .init([identifierFromPayload ?? 0])
}

@MainActor
private final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    init(navigationPath: Binding<NavigationPath>) {
        _navigationPath = navigationPath
    }
    
    @Binding
    var navigationPath: NavigationPath
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let extractedPath = path(from: response)
        print("Got \(extractedPath) from \(response)")

        // This is the line that doesn't work.
        // It doesn't trigger an update of the property in `watchOSNotificationActionHandlingRadar_Watch_AppApp`.
        navigationPath = extractedPath
    }
}

@main
struct watchOSNotificationActionHandlingRadar_Watch_AppApp: App {
    @State
    var navigationPath = NavigationPath()
    
    private var notificationDelegate: NotificationDelegate!
    
    init() {
        // Note: There's 0 documentation that explains how to handle notification actions in SwiftUI watchOS apps,
        // however, this seems to be what's required.
        let delegate = NotificationDelegate(navigationPath: $navigationPath)
        UNUserNotificationCenter.current().delegate = delegate
        self.notificationDelegate = delegate
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                ContentView(navigationPath: $navigationPath)
                    .navigationDestination(for: Int.self) { integer in
                        DetailScreen(integer: integer)
                    }
            }
            .onChange(of: navigationPath) { newNavigationPath in
                // This doesn't get called when `NotificationDelegate` updates `navigationPath`.
                print("New navigation path: \(newNavigationPath)")
            }
        }

        WKNotificationScene(controller: NotificationController.self,
                                category: "notification_category_identifier")
    }
}

struct DetailScreen: View {
    var integer: Int
    
    var body: some View {
        Text("\(integer)")
    }
}
