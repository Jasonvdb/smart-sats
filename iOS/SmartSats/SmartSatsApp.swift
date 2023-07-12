//
//  SmartSatsApp.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/06.
//

import SwiftUI

//TODO move to util and show in onboarding
func requestPushNotificationPermision(completionHandler: @escaping (Bool, Error?) -> Void) {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: completionHandler
    )
    UIApplication.shared.registerForRemoteNotifications()
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        //Permision is requested on coach view appearance
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       
        print("PUSH USER INFO")
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        
        print("PUSH USER INFO:")
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([[.banner, .badge, .sound]])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        print("***TOKEN \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError")
        print(error.localizedDescription)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
       
        print("PUSH USER INFO:::")
        print(userInfo)
                
        completionHandler()
    }
}

@main
struct SmartSatsApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject var ln = LN.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            print("***onForeground")
                            try await ln.start()
                        } catch {
                            print("Failed to stop node")
                        }
                    }
                }
            //MARK: TODO figure out why these events get called randomly
//                .onBackground {
//                    Task {
//                        do {
//                            print("***onBackground")
//                            try await ln.stop()
//                        } catch {
//                            print("Failed to stop node")
//                        }
//                    }
//                }
//                .onForeground {
//                    Task {
//                        do {
//                            print("***onForeground")
//                            try await ln.start()
//                        } catch {
//                            print("Failed to stop node")
//                        }
//                    }
//                }
        }
    }
}
