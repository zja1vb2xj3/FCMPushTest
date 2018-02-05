//
//  AppDelegate.swift
//  FCMPushTest
//
//  Created by Beaconyx on 2018. 2. 1..
//  Copyright © 2018년 Beaconyx. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let gcmMessageIDKey = "AIzaSyB835azFl9MxqT9cPXgS0Yz3yHG0lEB_S0"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self as MessagingDelegate
        
        initUNUserNotification(application: application)
        
        
        return true
    }
    
    func initUNUserNotification(application: UIApplication){
        /*ios 10 이상을 실행하는 기기에서는 앱 실행이 끝나기전에 대리자 개체를 UNUserNotificationCenter 개체에 할당하여 디스플레이 알림을 수신하고 FIRMessaging 개체에 할당하여 데이터 메세지를 수신해야 합니다. 예를들어 앱의 applicationWillFinishLaunching 또는 applicationDidFinishLaunching 메소드에서 할당해야 합니다.*/
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in})
        }else{
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let messageID = userInfo[gcmMessageIDKey]{
            print("Message ID: \(messageID)")
        }
        
        print("un ios10 userInfo: \(userInfo)")
        
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

//[START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        if let messageId = userInfo[gcmMessageIDKey]{
            print("Message ID: \(messageId)")
        }
        
        //백그라운드 상태에서는 상단에 푸쉬 바가 생기고 클릭을 하면 이곳에 데이터가 날라옴 포그라운드 상태에서는 바로 날라옴
        print("ios10 ㅁㅁㅁ: \(userInfo) end")
        
//        let keys = userInfo.keys
        
        if let aps = userInfo["aps"] as? NSDictionary{
            if let alert = aps["alert"] as? NSString{
                    print(alert)// 메세지 내용
            }
            
//            if let alert = aps["alert"] as? NSDictionary{
//                let title = alert["title"] as! NSString?
//                let body = alert["body"] as! NSString?
//
//                print("title: \(String(describing: title))")//고급옵션 제목
//                print("body: \(String(describing: body))")//메세지내용
//
//                //뱃지 구현 보류 공지사항 페이지는 누를때마다 서버에 접속 필요
//                //때마다 접속?
//            }
//        }
        
//
//        if let value1 = userInfo["value1"] as? NSString{
//            print("value1: \(value1)")// 맞춤 데이터
//        }
//
    
        
        completionHandler([])//Change this to your preferred presentation option
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageId = userInfo[gcmMessageIDKey]{
            print("Message ID: \(messageId)")
        }
        
        print("userNotificationCenter : \(userInfo)")
        
        completionHandler()
    }
}
//[END ios_10_message_handling]

extension AppDelegate : MessagingDelegate{
    //[START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("firebase registration token: \(fcmToken)")
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}



