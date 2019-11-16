//
//  AppDelegate.swift
//  AE
//
//  Created by MAC_MINI_6 on 18/03/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Firebase
import FirebaseMessaging
import GoogleMaps
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var backgroundSessionCompletionHandler : (() -> Void)?
  var downloadRequestStatus: ((_ model: MZDownloadModel, _ status: DownloadStatus) -> Void)?
  
  
  lazy var downloadManager: MZDownloadManager = {
    [unowned self] in
    let sessionIdentifer: String = "com.augmentedExperience.app.dowmloadManager.backgroundSession"
    
    var completion = backgroundSessionCompletionHandler
    
    let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
    return downloadmanager
  }()
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    IQKeyboardManager.shared.enable = true
    FirebaseApp.configure()
    Fabric.with([Crashlytics.self])
    GMSServices.provideAPIKey(SDK_KEY.GOOGLE_MAPS.rawValue)
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
    notificationsSetup(application)
//    Thread.sleep(forTimeInterval:3)

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let fbHandled = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    return /fbHandled
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
 
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

  }
  
  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    backgroundSessionCompletionHandler = completionHandler
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    firebaseHandler()
  }

  func applicationWillTerminate(_ application: UIApplication) {

  }

  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    if /UIApplication.topVC()?.isKind(of: MediaPreviewVC.self) {
      return UIInterfaceOrientationMask.all
    } else {
      return UIInterfaceOrientationMask.portrait
    }
  }
  
}

//MARK:- Notifications functions
extension AppDelegate {
  func notificationsSetup(_ app: UIApplication) {
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization( options: authOptions,completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      app.registerUserNotificationSettings(settings)
    }
    app.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self
  }
  
  func firebaseHandler() {
    Messaging.messaging().shouldEstablishDirectChannel = true
  }
}

//MARK:- UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    guard let userInfo = notification.request.content.userInfo as? [String : Any] else { return }
    if notification.request.identifier == "DOWNLOAD_COMPLETED" {
      handleDownloadNotification(data: userInfo, redirectToDwnlds: false)
    } else {
      guard let dict = notification.request.content.userInfo as? [String : Any] else {
        return
      }
      
      
      let notification = JSONHelper<PushNotification>().getCodableModel(data: dict)
      Toast.shared.showAlert(type: .notification, message: /notification?.message)

      
    }
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    guard let userInfo = response.notification.request.content.userInfo as? [String : Any] else { return }
    if response.notification.request.identifier == "DOWNLOAD_COMPLETED" {
      handleDownloadNotification(data: userInfo, redirectToDwnlds: true)
    } else {
      
    }
  }
  
  func handleDownloadNotification(data: [String : Any], redirectToDwnlds: Bool) {
    if redirectToDwnlds {
      UIApplication.topVC()?.tabBarController?.selectedIndex = 1
    } else {
      Toast.shared.showAlert(type: .success, message: VCLiteral.DOWNLOAD_BODY.localized)
    }
  }
  
}

//MARK:- MessagingDelegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("FCM_TOKEN_1:- \(fcmToken)")
    UserPreference.shared.firebaseToken = fcmToken
  }
}

//MARK:- MZDownloadManagerDelegate
extension AppDelegate: MZDownloadManagerDelegate {
  func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .DOWNLOADING)
    print("Progress:  ", downloadModel.progress)
  }
  
  func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel]) {
    print("Interrupted tasks")
  }
  
  func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
    print("Request started for: ", downloadModel.fileName)
  }
  
  func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .FAILED)
  }
  
  func downloadRequestDidRetry(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .DOWNLOADING)
  }
  
  func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .PAUSED)
  }
  
  func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .RESUMED)
  }
  
  func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .DOWNLOADED)
  }
  
  func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
    downloadRequestStatus?(downloadModel, .FAILED)
  }
  
  func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
    print("Download request destination not exist")
  }
}
