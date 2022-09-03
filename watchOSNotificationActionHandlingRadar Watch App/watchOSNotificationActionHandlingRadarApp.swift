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

/// A class implementing `UNUserNotificationCenterDelegate` in the natural way to be able to update a binding to `navigationPath`, whcih in fact does not work.
// Note: Without this main actor, if we perform `async` tasks in the `didReceive` method, the app crashes deep inside Apple's frameworks.
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

/// A hacky approach to implement `UNUserNotificationCenterDelegate` in order to be able to update `navigationPath` when handling a notification.
@MainActor
private final class NotificationDelegateWorkaround: NSObject, UNUserNotificationCenterDelegate {
    var handleResponse: ((UNNotificationResponse) -> Void)?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // We have to wait for the app UI to be set up,
        // since `navigateToDestination` is set in `onAppear`,
        // and that's the only way I could get it to work.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if let handleResponse = self.handleResponse {
                handleResponse(response)
            } else {
                print("Error: Notification response not set when received notification response")
            }
        }
    }
}



@main
struct watchOSNotificationActionHandlingRadar_Watch_AppApp: App {
    @State
    var navigationPath = NavigationPath()
    
    private var notificationDelegate: NotificationDelegate!
    private var notificationDelegateWorkaround: NotificationDelegateWorkaround!
    
    init() {
        // Note: There's 0 documentation that explains how to handle notification actions in SwiftUI watchOS apps,
        // however, this seems to be what's required.
        let delegate = NotificationDelegate(navigationPath: $navigationPath)
        UNUserNotificationCenter.current().delegate = delegate
        self.notificationDelegate = delegate
        
        let workaroundDelegate = NotificationDelegateWorkaround()
        self.notificationDelegateWorkaround = workaroundDelegate
        
        // Uncomment this to enable the workaround:
        // UNUserNotificationCenter.current().delegate = workaroundDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationPath) {
                ContentView(navigationPath: $navigationPath)
                    .navigationDestination(for: Int.self) { integer in
                        DetailScreen(integer: integer)
                    }
            }
            .onAppear {
                notificationDelegateWorkaround.handleResponse = {
                    navigationPath = path(from: $0)
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
